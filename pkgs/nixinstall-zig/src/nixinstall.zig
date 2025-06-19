const std = @import("std");
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

    const answer_as_enum = std.meta.stringToEnum(YesNoEnum, answer) orelse return default;

    switch (answer_as_enum) {
        .yes, .y, .@"true", .@"1" => return true,
        .no, .n, .@"false", .@"0" => return false,
    }
}

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    const allocator = gpa.allocator();

    var child: Child = .init(&.{ "hello" }, allocator);

    try child.spawn();
    const res = try child.wait();
    std.debug.print("Hello result: {any}\n", .{res});

    var httpClient: std.http.Client = .{ .allocator = allocator }; 
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

    var clone_process: Child = .init(&.{ "git", "clone", "https://github.com/lmacrini/dotfiles", "/tmp/config" }, allocator);

    if (std.fs.accessAbsolute("/tmp/config", .{ .mode = .read_write })) {
        const clone_again = try yesOrNo("config repo already found. clone again? [y] ", true);
        if (clone_again) {
            try std.fs.deleteTreeAbsolute("/tmp/config");
            try clone_process.spawn();
            _ = try clone_process.wait();
        }
    } else |_| {
        try clone_process.spawn();
        _ = try clone_process.wait();
    }
}
