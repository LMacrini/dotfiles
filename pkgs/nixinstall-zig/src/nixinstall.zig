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
    true,
    @"1",
    no,
    n,
    false,
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
        .yes, .y, .true, .@"1" => return true,
        .no, .n, .false, .@"0" => return false,
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

        const shell = std.posix.getenv("SHELL") orelse "bash";
        var shell_process: Child = .init(&.{shell}, allocator);
        _ = try shell_process.spawnAndWait();

        return;
    }

    while (true) {
        try stderr.writeAll("\n");

        var lsblk_process: Child = .init(&.{"lsblk"}, allocator);
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

            break :blk .init(&.{ "disko", "-m", "destroy,format,mount", "--yes-wipe-all-disks", "--arg", "disk", disk_path, "--arg", "swap", swap, "/tmp/config/disko/swap.nix" }, allocator);
        } else .init(&.{ "disko", "-m", "destroy,format,mount", "--yes-wipe-all-disks", "--arg", "disk", disk_path, "/tmp/config/disko/no-swap.nix" }, allocator);

        const res = try disko_process.spawnAndWait();
        std.debug.print("res: {}\n", .{res});
        break;
    }
}

fn getPassword(buf: []u8) ![]const u8 {
    var buf1 = buf;
    var buf2: [64]u8 = undefined;
    if (buf1.len > buf2.len) {
        buf1.len = buf2.len;
    }

    while (true) {
        try stderr.writeAll("please enter root password: ");
        const password1 = stdin.readUntilDelimiterOrEof(buf1, '\n') catch |err| switch (err) {
            error.StreamTooLong => {
                try stderr.writeAll("password too long, please try again\n");
                continue;
            },
            else => return err,
        } orelse "";

        try stderr.writeAll("please enter root password again: ");
        const password2 = stdin.readUntilDelimiterOrEof(&buf2, '\n') catch |err| switch (err) {
            error.StreamTooLong => {
                try stderr.writeAll("password too long, please try again\n");
                continue;
            },
            else => return err,
        } orelse "";

        if (std.mem.eql(u8, password1, password2)) return password1;

        try stderr.writeAll("passwords do not match, please try again\n");
    }
}

fn install(allocator: std.mem.Allocator) !void {
    var password_buf: [64]u8 = undefined;
    const passwd = try getPassword(&password_buf);

    const States = enum {
        hostname,
        hardware_config,
        install,
    };

    var host_buf: [64]u8 = undefined;
    var host: []const u8 = undefined;

    var hosts_dir = try std.fs.openDirAbsolute("/tmp/config/hosts", .{});
    defer hosts_dir.close();

    installation: switch (States.hostname) {
        .hostname => {
            try stderr.writeAll("please choose host to install ");
            host = stdin.readUntilDelimiterOrEof(&host_buf, '\n') catch |err| switch (err) {
                error.StreamTooLong => {
                    try stderr.writeAll("host name too long, please try again\n");
                    continue :installation .hostname;
                },
                else => return err,
            } orelse "";

            if (std.mem.eql(u8, host, "new")) {
                const shell = std.posix.getenv("SHELL") orelse "bash";
                var shell_process: Child = .init(&.{shell}, allocator);
                shell_process.cwd_dir = try std.fs.openDirAbsolute("/tmp/config", .{});
                _ = try shell_process.spawnAndWait();
                try stderr.writeAll("\n");
                continue :installation .hostname;
            }

            if (hosts_dir.access(host, .{})) {
                try stderr.writeAll("not a valid host, please try again\n");
                continue :installation .hostname;
            } else |_| {}

            continue :installation .hardware_config;
        },
        else => unreachable,
    }

    var install_process: Child = .init(&.{ "nixos-install", "--flake", "/tmp/config#vm", "--no-channel-copy" }, allocator);
    install_process.stdin_behavior = .Pipe;

    try install_process.spawn();
    try install_process.stdin.?.writeAll(passwd);

    std.debug.print("{}", .{try install_process.wait()});
}

pub fn main() !void {
    if (builtin.os.tag != .linux) {
        @compileError("only intended for linux");
    }

    var gpa: std.heap.DebugAllocator(.{}) = .init;
    const allocator = gpa.allocator();
    defer _ = gpa.detectLeaks();

    var hello_process: Child = .init(&.{"hello"}, allocator);
    _ = try hello_process.spawnAndWait();

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
        error.MessageNotCompleted,
        => {
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
        try stderr.print("unexpected result: {s} {d}", .{ @tagName(online_check.status), @intFromEnum(online_check.status) });
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

    try stderr.writeAll("\n");

    try install(allocator);
}
