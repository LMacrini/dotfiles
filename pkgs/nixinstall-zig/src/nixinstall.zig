const std = @import("std");
const builtin = @import("builtin");
const io = std.io;
const Child = std.process.Child;

const stdout = io.getStdOut().writer();
const stdin = io.getStdIn().reader();
const stderr = io.getStdErr().writer();

const YesNoEnum = enum {
    yes,
    y,
    @"true",
    @"1",
    no,
    n,
    @"false",
    @"0",
};

fn yesOrNo(msg: []const u8, default: bool) !bool {
    try stderr.writeAll(msg);
    var buf: [32]u8 = undefined;
    const answer = stdin.readUntilDelimiterOrEof(&buf, '\n') catch |err| switch (err) {
        error.StreamTooLong => return default,
        else => return err,
    } orelse return default;

    _ = std.ascii.lowerString(&buf, answer);
    
    const answer_as_enum = std.meta.stringToEnum(YesNoEnum, answer) orelse return default;

    switch (answer_as_enum) {
        .yes, .y, .@"true", .@"1" => return true,
        .no, .n, .@"false", .@"0" => return false,
    }
}

fn cloneRepo(allocator: std.mem.Allocator) !Child.Term {
    var child_process: Child = .init(&.{ "git", "clone", "https://github.com/lmacrini/dotfiles", "/tmp/config" }, allocator);
    return try child_process.spawnAndWait();
}

fn getTotalMem() !u64 {
    const mem_info = try std.fs.openFileAbsolute("/proc/meminfo", .{ .mode = .read_only });
    var buf: [64]u8 = undefined;

    const reader = mem_info.reader();
    
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (std.mem.startsWith(u8, line, "MemTotal:")) {
            var it = std.mem.tokenizeScalar(u8, line, ' ');
            _ = it.next();
            const mem = while (it.next()) |token| {
                if (!std.mem.eql(u8, token, &.{})) {
                    break token;
                }
            } else unreachable;

            return try std.fmt.parseInt(u64, mem, 10);
        }
    }
    unreachable;
}

fn partitionDrives(allocator: std.mem.Allocator) !void {
    const manual_partition = try yesOrNo("do you want to partition drives manually? [n] ", false);
    try stderr.writeAll("\n");

    if (manual_partition) {
        try stderr.writeAll("please partition drives and mount main partition on /mnt and boot partition on /mnt/boot\n");
        try stderr.writeAll("optionally you can mount a home partition onto /mnt/home (untested)\n");
        try stderr.writeAll("(write \"exit\" to exit)\n");
        try stderr.writeAll("\n");

        var buf: [1024]u8 = undefined;
        var cmd: []const u8 = undefined;

        var args_buf: [32][]const u8 = undefined;
        outer: while (true) {
            try stderr.writeAll("> ");
            cmd = stdin.readUntilDelimiterOrEof(&buf, '\n') catch |err| switch (err) {
                error.StreamTooLong => {
                    try stderr.writeAll("command too long, please try again\n");
                    continue;
                },
                else => return err,
            } orelse continue;

            if (std.mem.eql(u8, cmd, "exit")) break;
            if (std.mem.eql(u8, cmd, "")) continue;

            var args: [][]const u8 = &args_buf;
            args.len = 1;

            var prev_split_idx: usize, var in_quotes = .{0, false};
            for (cmd, 0..) |char, i| {
                if (char == ' ' and !in_quotes) {
                    if (args.len >= args_buf.len) {
                        try stderr.writeAll("too many arguments, please try again\n");
                        continue :outer;
                    }
                    const split_idx = if (i > 0 and cmd[i-1] == '"') i-1 else i;
                    args[args.len - 1] = cmd[prev_split_idx..split_idx];
                    prev_split_idx = i+1;
                    args.len += 1;
                } else if (char == '"') {
                    if (!in_quotes and i > 0 and cmd[i-1] != ' ' or in_quotes and i + 1 < cmd.len and cmd[i + 1] != ' ') {
                        try stderr.writeAll("parsing error, please try again\n");
                        continue :outer;
                    }
                    if (!in_quotes) {
                        prev_split_idx += 1;
                    }
                    in_quotes = !in_quotes;
                }
            }

            {
                const split_idx = if (cmd.len > 1 and cmd[cmd.len - 1] == '"') cmd.len-1 else cmd.len; 
                args[args.len - 1] = cmd[prev_split_idx..split_idx];
            }

            var cmd_process: Child = .init(args, allocator);
            _ = cmd_process.spawnAndWait() catch |err| switch (err) {
                error.FileNotFound => {
                    try stderr.writeAll("unknown command, please try again\n");
                    continue;
                },
                else => {
                    try stderr.print("an error occurred, please try again: {}\n" , .{err});
                    continue;
                },
            };
        }

        return;
    }

    while (true) {
        try stderr.writeAll("\n");

        var lsblk_process: Child = .init(&.{ "lsblk" }, allocator);
        _ = try lsblk_process.spawnAndWait();
        
        try stderr.writeAll("\n");

        var disk_buf: [64]u8 = undefined;
        var swap_buf: [64]u8 = undefined;
        var raw_buf: [64]u8 = undefined;

        try stderr.writeAll("which disk do you want to use? ");
        const disk = stdin.readUntilDelimiterOrEof(&raw_buf, '\n') catch |err| switch (err) {
            error.StreamTooLong => {
                try stderr.writeAll("disk name too long, please try again\n");
                continue;
            },
            else => return err,
        } orelse {
            try stderr.writeAll("please try again\n");
            continue;
        };
        
        const disk_path = try std.fmt.bufPrint(&disk_buf, "\"/dev/{s}\"", .{disk});

        var disko_process: Child = if (try yesOrNo("do you want a swap file? [n] ", false)) blk: {
            const default_swap_size = try getTotalMem();
            var swap: []const u8 = undefined;

            while (true) {
                try stderr.print("how much swap do you want? (in GiB) [{d:0}] ", .{default_swap_size / (1 << 20)});

                swap = stdin.readUntilDelimiterOrEof(&raw_buf, '\n') catch |err| switch (err) {
                    error.StreamTooLong => {
                        try stderr.writeAll("Too many characters, please try again\n");
                        continue;
                    },
                    else => return err,
                } orelse "";

                if (std.mem.eql(u8, swap, "")) {
                    swap = std.fmt.bufPrintIntToSlice(&raw_buf, default_swap_size, 10, .lower, .{});
                } else {
                    const swap_int = std.fmt.parseInt(u64, swap, 10) catch |err| switch (err) {
                        error.InvalidCharacter => {
                            try stderr.writeAll("Invalid character, please try again\n");
                            continue;
                        },
                        error.Overflow => {
                            try stderr.writeAll("Number too big, please try again\n");
                            continue;
                        },
                    };
                    if (swap_int * 2 > default_swap_size and !try yesOrNo("warning: swap is greater than 2 times the total ram. are you sure you want to continue? [n] ", false)) {
                        continue;
                    }
                    if (swap_int > 32 * (1 << 30) and !try yesOrNo("warning: swap is greater than 32 GiB. are you sure you want to continue? [n] ", false)) {
                        continue;
                    }

                    swap = std.fmt.bufPrintIntToSlice(&raw_buf, swap_int, 10, .lower, .{});
                }

                break;
            }

            swap = try std.fmt.bufPrint(&swap_buf, "\"{s}k\"", .{swap});

            if (!try yesOrNo("are you sure you want to continue? this will wipe all the information on the drive [n] ", false)) continue;

            break :blk .init(&.{"disko", "-m", "destroy,format,mount", "--yes-wipe-all-disks", "--arg", "disk", disk_path, "--arg", "swap", swap, "/tmp/config/disko/swap.nix"}, allocator);
        } else .init(&.{ "disko", "-m", "destroy,format,mount", "--yes-wipe-all-disks", "--arg", "disk", disk_path, "/tmp/config/disko/no-swap.nix" }, allocator);

        const res = try disko_process.spawnAndWait();
        std.debug.print("res: {}\n", .{res});
        break;
    }
}

pub fn main() !void {
    if (builtin.os.tag != .linux) {
        @compileError("only intended for linux");
    }

    var gpa: std.heap.DebugAllocator(.{}) = .init;
    const allocator = gpa.allocator();
    defer _ = gpa.detectLeaks();

    if (std.os.linux.getuid() != 0) { // NOTE: this getuid() function will be under std.posix in the future
        try stderr.writeAll("please run nixinstall with sudo");
        std.process.exit(1);
    }

    var httpClient: std.http.Client = .{ .allocator = allocator }; 
    defer httpClient.deinit();
    const online_check = httpClient.fetch(.{
        .location = .{ .url = "https://github.com" },
    }) catch |err| switch (err) {
        error.TemporaryNameServerFailure,
        error.TlsAlert,
        error.UnexpectedReadFailure,
        error.MessageNotCompleted, => {
            std.debug.print("failed to connect to github. are you connected to the internet?\n", .{});
            std.debug.print("if you are connected to the internet but github is down, please try again later\n", .{});
            std.process.exit(1);
        },
        else => {
            std.debug.print("an unexpected error occured when connecting to github: {}", .{err});
            std.process.exit(1);
        },
    };

    if (online_check.status != .ok) {
        // TODO: return different message based on result, probably using @intFromEnum and ranges
        try stderr.print("unexpected result: {s} {d}", .{@tagName(online_check.status), @intFromEnum(online_check.status)});
        std.process.exit(1);
    }

    if (std.fs.accessAbsolute("/tmp/config", .{ .mode = .read_write })) {
        const clone_again = try yesOrNo("config repo already found. clone again? [y] ", true);
        if (clone_again) {
            try std.fs.deleteTreeAbsolute("/tmp/config");
            _ = try cloneRepo(allocator);
        }
    } else |_| {
        _ = try cloneRepo(allocator);
    }

    try stderr.writeAll("\n");

    try partitionDrives(allocator);
}
