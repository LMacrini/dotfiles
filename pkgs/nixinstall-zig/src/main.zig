fn yesOrNo(stdout: *Io.Writer, stdin: *Io.Reader, msg: []const u8, default: bool) !bool {
    const Options = enum {
        yes,
        y,
        true,
        t,
        @"1",
        no,
        n,
        false,
        f,
        @"0",
    };

    try stdout.writeAll(msg);
    try stdout.writeByte(' ');
    try stdout.flush();

    const response = try stdin.takeDelimiterExclusive('\n');
    stdin.toss(1);

    for (response) |*c| {
        c.* = std.ascii.toLower(c.*);
    }

    const answer = std.meta.stringToEnum(Options, response) orelse return default;
    return switch (answer) {
        .yes, .y, .true, .t, .@"1" => true,
        .no, .n, .false, .f, .@"0" => false,
    };
}

fn logErr(io: Io, str: []const u8) void {
    var buf: [4096]u8 = undefined;
    var stderr: Io.File.Writer = .init(.stderr(), io, &buf);
    stderr.interface.writeAll(str) catch {};
    stderr.interface.flush() catch {};
}

fn getPassword(gpa: std.mem.Allocator, stdout: *Io.Writer, stdin: *Io.Reader) ![]u8 {
    const termios = try std.posix.tcgetattr(std.posix.STDIN_FILENO);
    defer std.posix.tcsetattr(std.posix.STDIN_FILENO, .FLUSH, termios) catch {
        std.log.warn("failed to reset stdin, you may not see what you type", .{});
    };

    var noecho = termios;
    noecho.lflag.ECHO = false;
    try std.posix.tcsetattr(std.posix.STDIN_FILENO, .FLUSH, noecho);

    while (true) {
        try stdout.writeAll("please enter root password: ");
        try stdout.flush();

        const pass1 = blk: {
            const pass = try stdin.takeDelimiterInclusive('\n');
            defer std.crypto.secureZero(u8, pass);

            break :blk try gpa.dupe(u8, pass);
        };
        errdefer {
            std.crypto.secureZero(u8, pass1);
            gpa.free(pass1);
        }

        try stdout.writeAll("\nplease enter root password again: ");
        try stdout.flush();

        const pass2 = try stdin.takeDelimiterInclusive('\n');
        defer std.crypto.secureZero(u8, pass2);

        try stdout.writeByte('\n');
        try stdout.flush();

        if (std.mem.eql(u8, pass1, pass2)) {
            return pass1;
        }

        try stdout.writeAll("passwords were not the same, please try again\n");
    }
}

fn partitionDrives(
    io: Io,
    gpa: std.mem.Allocator,
    stdout: *Io.Writer,
    stdin: *Io.Reader,
    shell: *Child,
) !?Child {
    const manual_partition = try yesOrNo(
        stdout,
        stdin,
        "do you want to partition drives manually? [n]",
        false,
    );
    try stdout.writeByte('\n');

    if (manual_partition) {
        try stdout.writeAll(
            \\please partition drives and mount main partition on /mnt and boot partition on /mnt/boot
            \\optionally you can mount a home partition onto /mnt/home (untested)
            \\(write "exit" to exit)
            \\
        );
        try stdout.flush();

        _ = try shell.spawnAndWait(io);
        return null;
    }

    const mem_info = try Io.Dir.openFileAbsolute(io, "/proc/meminfo", .{
        .mode = .read_only,
        .allow_directory = false,
    });
    defer mem_info.close(io);

    var mem_info_buf: [64]u8 = undefined;
    var mem_info_reader = mem_info.reader(io, &mem_info_buf);

    const default_swap =
        while (try mem_info_reader.interface.takeDelimiter('\n')) |line| {
            var it = std.mem.tokenizeScalar(u8, line, ' ');

            if (std.mem.eql(u8, it.next().?, "MemTotal:")) {
                break try std.fmt.parseInt(u64, it.next().?, 10);
            }
        } else unreachable;

    while (true) {
        try stdout.writeByte('\n');
        try stdout.flush();

        var lsblk: Child = .init(&.{"lsblk"}, gpa);
        _ = try lsblk.spawnAndWait(io);

        try stdout.writeAll(
            \\
            \\which disk do you want to use?
        );
        try stdout.writeByte(' ');
        try stdout.flush();

        const disk = stdin.takeDelimiterExclusive('\n') catch |err| switch (err) {
            error.StreamTooLong => {
                std.log.err("disk name too long, please try again", .{});
                continue;
            },
            else => return err,
        };
        stdin.toss(1);

        const disk_path = try std.fmt.allocPrint(gpa, "\"/dev/{s}\"", .{disk});
        defer gpa.free(disk_path);

        var swap: []const u8 = &.{};
        defer gpa.free(swap);

        var disko: Child = if (try yesOrNo(stdout, stdin, "do you want a swap file? [y]", true))
            (while (true) {
                try stdout.print("how much swap do you want? (in GiB) [{d:0}] ", .{default_swap / (1 << 20)});
                try stdout.flush();
                const swap_input = stdin.takeDelimiterExclusive('\n') catch |err| switch (err) {
                    error.StreamTooLong => {
                        std.log.err("disk name too long, please try again", .{});
                        continue;
                    },
                    else => return err,
                };
                stdin.toss(1);

                if (swap_input.len == 0) {
                    swap = try std.fmt.allocPrint(gpa, "\"{d}k\"", .{default_swap});
                } else {
                    const swap_int = (std.fmt.parseInt(u64, swap_input, 10) catch |err| switch (err) {
                        error.InvalidCharacter => {
                            std.log.err("Invalid character, please try again", .{});
                            continue;
                        },
                        error.Overflow => {
                            std.log.err("Number too big, please try again", .{});
                            continue;
                        },
                    }) * (1 << 20);

                    std.log.debug("{d} {d} {d}", .{ swap_int, default_swap, 32 * (1 << 30) });

                    if (swap_int *| 2 > default_swap and !try yesOrNo(
                        stdout,
                        stdin,
                        "warning: swap is greater than 2 times the total ram. are you sure you want to continue? [n]",
                        false,
                    )) continue;

                    if (swap_int > 32 * (1 << 30) and !try yesOrNo(
                        stdout,
                        stdin,
                        "warning: swap is greater than 32 GiB. are you sure you want to continue? [n]",
                        false,
                    )) continue;

                    swap = try std.fmt.allocPrint(gpa, "\"{d}k\"", .{swap_int});
                }

                break .init(&.{
                    "disko",
                    "-m",
                    "destroy,format,mount",
                    "--yes-wipe-all-disks",
                    "--arg",
                    "disk",
                    disk_path,
                    "--arg",
                    "swap",
                    swap,
                    "/tmp/config/disko/swap.nix",
                }, gpa);
            })
        else
            .init(&.{
                "disko",
                "-m",
                "destroy,format,mount",
                "--yes-wipe-all-disks",
                "--arg",
                "disk",
                disk_path,
                "/tmp/config/disko/no-swap.nix",
            }, gpa);

        if (!try yesOrNo(
            stdout,
            stdin,
            "are you sure you want to continue? this will wipe all information on the drive [n]",
            false,
        )) continue;

        disko.stderr_behavior = .Pipe;
        disko.stdout_behavior = .Ignore;

        try disko.spawn(io);

        return disko;
    }
}

fn copyDir(io: Io, gpa: std.mem.Allocator, src: Io.Dir, dst: Io.Dir) !void {
    var walker = try src.walk(gpa);
    defer walker.deinit();

    while (try walker.next(io)) |entry| switch (entry.kind) {
        .directory => {
            const dir = dst.createDirPathOpen(io, entry.path, .{
                .open_options = .{
                    .iterate = true,
                },
                .permissions = .default_dir,
            }) catch {
                std.log.warn("failed to create directory '{s}'", .{entry.path});
                continue;
            };
            defer dir.close(io);

            dir.setOwner(io, 1000, 100) catch {
                std.log.warn("failed to set owner for directory '{s}'", .{entry.path});
                continue;
            };
        },
        .file => {
            src.copyFile(entry.path, dst, entry.path, io, .{
                .permissions = .default_file,
            }) catch {
                std.log.warn("failed to copy file '{s}'", .{entry.path});
                continue;
            };

            // TODO: use uncomment when it's fixed
            // dst.setFileOwner(io, entry.path, 1000, 100, .{}) catch {
            //     std.log.warn("failed to set owner for file '{s}'", .{entry.path});
            //     continue;
            // };
        },
        else => return error.Unhandled,
    };
}

fn getHostInfo(
    io: Io,
    gpa: std.mem.Allocator,
    stdout: *Io.Writer,
    stdin: *Io.Reader,
    shell: *Child,
) ![]u8 {
    shell.cwd = "/tmp/config";
    defer {
        shell.cwd = null;
    }

    const hosts_dir: Io.Dir = try .openDirAbsolute(io, "/tmp/config/hosts", .{});
    defer hosts_dir.close(io);

    var host_name = while (true) {
        try stdout.writeAll(
            \\which host would you like to build?
            \\(write new to create one)
        );
        try stdout.writeByte(' '); //gets autoformatted out of the multiline string
        try stdout.flush();

        const host = try stdin.takeDelimiterExclusive('\n');
        stdin.toss(1);

        if (!std.mem.eql(u8, host, "new")) {
            if (hosts_dir.access(io, host, .{})) {
                break try gpa.dupe(u8, host);
            } else |err| switch (err) {
                error.FileNotFound => {
                    try stdout.writeAll("host not found, please try again\n");
                    continue;
                },
                else => return err,
            }
        }

        _ = try shell.spawnAndWait(io);
    };
    errdefer gpa.free(host_name);

    const host_dir = hosts_dir.openDir(io, host_name, .{}) catch |err| switch (err) {
        error.FileNotFound => unreachable,
        else => return err,
    };
    defer host_dir.close(io);

    const create_hardware_file: bool = if (host_dir.access(io, "hardware-configuration.nix", .{})) blk: {
        const ans = try yesOrNo(
            stdout,
            stdin,
            "hardware-configuration.nix found in this host, do you wish to replace it? [n]",
            false,
        );

        if (ans) try host_dir.deleteFile(io, "hardware-configuration.nix");
        break :blk ans;
    } else |err| if (err == error.FileNotFound) true else return err;

    if (create_hardware_file) {
        var process: Child = .init(&.{
            "nixos-generate-config",
            "--root",
            "/mnt",
            "--show-hardware-config",
        }, gpa);
        process.stdout_behavior = .Pipe;
        process.stderr_behavior = .Pipe;
        try process.spawn(io);

        var poller = Io.poll(gpa, enum { stdout, stderr }, .{
            .stdout = process.stdout.?,
            .stderr = process.stderr.?,
        });
        defer poller.deinit();

        const stdout_r = poller.reader(.stdout);
        const stderr_r = poller.reader(.stderr);

        while (try poller.poll()) {}

        const term = try process.wait(io);

        if (term != .Exited or term.Exited != 0) {
            logErr(io, stderr_r.buffer[0..stderr_r.end]);
            return error.ConfigGenerationFailed;
        }

        const hardware_file = try host_dir.createFile(io, "hardware-configuration.nix", .{
            .exclusive = true,
        });
        defer hardware_file.close(io);

        var buf: [4096]u8 = undefined;
        var writer = hardware_file.writer(io, &buf);
        try writer.interface.writeAll(stdout_r.buffer[0..stdout_r.end]);
        try writer.interface.flush();
    }

    host_name = try gpa.realloc(host_name, host_name.len + 2);
    @memmove(host_name[2..], host_name.ptr);
    host_name[0..2].* = ".#".*;

    return host_name;
}

var dba: std.heap.DebugAllocator(.{}) = .init;

pub fn main() !u8 {
    if (std.posix.getuid() != 0) {
        std.log.err("please run nixinstall as root", .{});
        return 1;
    }

    defer _ = if (builtin.mode == .Debug) dba.deinit();
    const gpa = if (builtin.mode == .Debug)
        dba.allocator()
    else
        std.heap.smp_allocator;

    var threaded: Io.Threaded = .init_single_threaded;
    defer threaded.deinit();
    const io = threaded.io();

    var stdout_buf: [4096]u8 = undefined;
    var stdout_fw: Io.File.Writer = .init(.stdout(), io, &stdout_buf);
    const stdout = &stdout_fw.interface;

    var stdin_buf: [128]u8 = undefined;
    var stdin_fr: Io.File.Reader = .init(.stdin(), io, &stdin_buf);
    const stdin = &stdin_fr.interface;

    var http_client: std.http.Client = .{ .allocator = gpa, .io = io };
    defer http_client.deinit();
    const online_check = http_client.fetch(.{
        .location = .{ .url = "https://git.serversmp.xyz" },
    }) catch |err| switch (err) {
        error.NetworkDown,
        error.Timeout,
        error.ConnectionRefused,
        error.HostUnreachable,
        error.NetworkUnreachable,
        error.UnknownHostName,
        error.NameServerFailure,
        error.DetectingNetworkConfigurationFailed,
        error.ResolvConfParseFailed,
        error.InvalidDnsARecord,
        error.InvalidDnsAAAARecord,
        error.InvalidDnsCnameRecord,
        error.HttpConnectionClosing,
        error.TooManyHttpRedirects,
        => {
            std.log.err(
                \\failed to connect to forgejo ({}). are you connected to the internet?
                \\if you are connected to the internet but forgejo is down, please try again later
            , .{err});
            return 1;
        },
        else => {
            std.log.err("an unexpected error occured when connecting to forgejo: {}", .{err});
            return 1;
        },
    };

    if (online_check.status != .ok) {
        if (online_check.status.phrase()) |phrase| {
            std.log.err("unexpected result: {s} {d}", .{ phrase, @intFromEnum(online_check.status) });
            return 1;
        } else {
            std.log.err("unexpected result: {d}", .{@intFromEnum(online_check.status)});
            return 1;
        }
    }

    const clone: bool = if (Io.Dir.accessAbsolute(io, "/tmp/config", .{})) blk: {
        const clone_again = try yesOrNo(stdout, stdin, "config repo already found, clone again? [y]", true);
        if (clone_again) {
            try Io.Dir.deleteTree(.cwd(), io, "/tmp/config");
        }
        break :blk clone_again;
    } else |err| blk: {
        if (err != error.FileNotFound) return err;
        break :blk true;
    };

    if (clone) {
        var process: Child = .init(&.{
            "git",
            "clone",
            "https://git.serversmp.xyz/seija/dotfiles",
            "/tmp/config",
        }, gpa);
        _ = try process.spawnAndWait(io);
    }

    const shell = std.process.getEnvVarOwned(gpa, "SHELL") catch |err| switch (err) {
        error.EnvironmentVariableNotFound => try gpa.dupe(u8, "bash"),
        else => return err,
    };
    defer gpa.free(shell);
    var shell_process: Child = .init(&.{shell}, gpa);

    try stdout.writeByte('\n');

    var drive_process = try partitionDrives(io, gpa, stdout, stdin, &shell_process);
    errdefer _ = if (drive_process) |*p| p.kill(io) catch {};

    try stdout.writeByte('\n');

    const password = try getPassword(gpa, stdout, stdin);
    defer {
        std.crypto.secureZero(u8, password);
        gpa.free(password);
    }

    try stdout.writeByte('\n');

    if (drive_process) |*p| {
        var poller = Io.poll(gpa, enum { stderr }, .{
            .stderr = p.stderr.?,
        });
        defer poller.deinit();

        const stderr_r = poller.reader(.stderr);

        while (try poller.poll()) {}

        const term = try p.wait(io);

        if (term != .Exited or term.Exited != 0) {
            logErr(io, stderr_r.buffer[0..stderr_r.end]);
            return error.DrivePartitionFailed;
        }
    }

    const host = try getHostInfo(io, gpa, stdout, stdin, &shell_process);
    defer gpa.free(host);

    var install: Child = .init(&.{
        "nixos-install",
        "--flake",
        host,
        "--no-channel-copy",
    }, gpa);
    install.cwd = "/tmp/config";
    install.stdin_behavior = .Pipe;
    try install.spawn(io);

    for (0..2) |_| try install.stdin.?.writeStreamingAll(io, password);

    const term = try install.wait(io);

    if (term != .Exited or term.Exited != 0) {
        std.log.err("build failed, please try again", .{});
        return 1;
    }

    try stdout.writeAll("build complete, you may reboot\n");
    try stdout.flush();

    const tmp_config: Io.Dir = try .openDirAbsolute(io, "/tmp/config", .{
        .iterate = true,
    });
    defer tmp_config.close(io);

    const dotfiles: Io.Dir = try .createDirPathOpen(.cwd(), io, "/mnt/home/lioma/dotfiles", .{
        .open_options = .{ .iterate = true }, // setOwner requires iterate
    });
    defer dotfiles.close(io);

    try dotfiles.setOwner(io, 1000, 100);

    try copyDir(io, gpa, tmp_config, dotfiles);

    return 0;
}

const std = @import("std");
const builtin = @import("builtin");
const Io = std.Io;
const Child = std.process.Child;
