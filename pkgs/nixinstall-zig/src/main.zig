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
    shell_opts: *const SpawnOptions,
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

        var shell = try std.process.spawn(io, shell_opts.*);
        _ = try shell.wait(io);
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

        var lsblk = try std.process.spawn(io, .{
            .argv = &.{"lsblk"},
        });
        _ = try lsblk.wait(io);

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

        if (try yesOrNo(stdout, stdin, "do you want a swap file? [y]", true))
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

                return try std.process.spawn(io, .{
                    .argv = &.{
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
                    },
                    .stdout = .ignore,
                    .stderr = .pipe,
                });
            })
        else {
            return try std.process.spawn(io, .{
                .argv = &.{
                    "disko",
                    "-m",
                    "destroy,format,mount",
                    "--yes-wipe-all-disks",
                    "--arg",
                    "disk",
                    disk_path,
                    "/tmp/config/disko/no-swap.nix",
                },
                .stdout = .ignore,
                .stderr = .pipe,
            });
        }

        // TODO: don't early return so this runs or smth
        if (!try yesOrNo(
            stdout,
            stdin,
            "are you sure you want to continue? this will wipe all information on the drive [n]",
            false,
        )) continue;
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
    shell_opts: *const SpawnOptions,
) ![]u8 {
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

        var shell = try std.process.spawn(io, shell_opts.*);
        _ = try shell.wait(io);
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

    // TODO: get rid of false and delete other if when "setUpChildIo" doesn't
    // panic with TODO on .file
    if (false and create_hardware_file) {
        var term: std.process.Child.Term = .{ .exited = 0 };

        const hardware_file = try host_dir.createFile(io, "hardware-configuration.nix", .{
            .exclusive = true,
        });
        defer if (term == .exited and term.exited == 0)
            hardware_file.close(io);

        var process = try std.process.spawn(io, .{
            .argv = &.{
                "nixos-generate-config",
                "--root",
                "/mnt",
                "--show-hardware-config",
            },
            .stdout = .{ .file = hardware_file },
            .stderr = .pipe,
        });

        var aw: Io.Writer.Allocating = .init(gpa);
        defer aw.deinit();

        var buf: [4096]u8 = undefined;
        var reader = process.stdout.?.reader(io, &buf);

        _ = try reader.interface.streamRemaining(&aw.writer);

        term = try process.wait(io);

        if (term != .exited or term.exited != 0) {
            logErr(io, aw.written());

            hardware_file.close(io);
            host_dir.deleteFile(io, "hardware-configuration.nix") catch {
                std.log.warn("failed to delete potentially badly generated hardware config", .{});
            };

            return error.ConfigGenerationFailed;
        }
    }
    if (create_hardware_file) {
        var term: std.process.Child.Term = .{ .exited = 0 };

        const hardware_file = try host_dir.createFile(io, "hardware-configuration.nix", .{
            .exclusive = true,
        });
        defer if (term == .exited and term.exited == 0)
            hardware_file.close(io);

        var process = try std.process.spawn(io, .{
            .argv = &.{
                "nixos-generate-config",
                "--root",
                "/mnt",
                "--show-hardware-config",
            },
            .stdout = .pipe,
            .stderr = .pipe,
        });

        var mr_buf: Io.File.MultiReader.Buffer(2) = undefined;
        var multi_reader: Io.File.MultiReader = undefined;
        multi_reader.init(gpa, io, mr_buf.toStreams(), &.{ process.stdout.?, process.stderr.? });
        defer multi_reader.deinit();

        try multi_reader.fillRemaining(.none);
        try multi_reader.checkAnyError();

        term = try process.wait(io);

        if (term != .exited or term.exited != 0) {
            logErr(io, multi_reader.reader(1).buffered());

            hardware_file.close(io);
            host_dir.deleteFile(io, "hardware-configuration.nix") catch {
                std.log.warn("failed to delete potentially badly generated hardware config", .{});
            };

            return error.ConfigGenerationFailed;
        }

        try hardware_file.writePositionalAll(io, multi_reader.reader(0).buffered(), 0);
    }

    host_name = try gpa.realloc(host_name, host_name.len + 2);
    @memmove(host_name[2..], host_name.ptr);
    host_name[0..2].* = ".#".*;

    return host_name;
}

const use_debug_allocator = builtin.mode == .Debug;
var debug_allocator: std.heap.DebugAllocator(.{}) = .init;

pub fn main(init: std.process.Init.Minimal) !u8 {
    if (std.os.linux.getuid() != 0) {
        std.log.err("please run nixinstall as root", .{});
        return 1;
    }

    const gpa = if (use_debug_allocator)
        debug_allocator.allocator()
    else
        std.heap.smp_allocator;

    defer if (use_debug_allocator) {
        _ = debug_allocator.deinit();
    };

    var threaded: Io.Threaded = .init(gpa, .{
        .environ = init.environ,
    });
    defer threaded.deinit();
    const io = threaded.io();

    var stdout_buf: [4096]u8 = undefined;
    var stdout_fw: Io.File.Writer = .initStreaming(.stdout(), io, &stdout_buf);
    const stdout = &stdout_fw.interface;

    var stdin_buf: [128]u8 = undefined;
    var stdin_fr: Io.File.Reader = .initStreaming(.stdin(), io, &stdin_buf);
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
        var process = try std.process.spawn(io, .{
            .argv = &.{
                "git",
                "clone",
                "https://git.serversmp.xyz/seija/dotfiles",
                "/tmp/config",
            },
        });
        const term = try process.wait(io);
        if (term != .exited or term.exited != 0) {
            switch (term) {
                inline else => |t| {
                    std.log.err("failed to clone repo ({t} {})", .{ term, t });
                },
            }
            return error.CloneFailed;
        }
    }

    const conf_dir: Io.Dir = try .openDirAbsolute(io, "/tmp/config", .{
        .iterate = true,
    });
    defer conf_dir.close(io);

    const shell = init.environ.getPosix("SHELL") orelse "bash";
    const shell_opts: SpawnOptions = .{
        .argv = &.{shell},
        .cwd = .{ .dir = conf_dir },
    };

    try stdout.writeByte('\n');

    var drive_process = try partitionDrives(io, gpa, stdout, stdin, &shell_opts);
    errdefer _ = if (drive_process) |*p| p.kill(io);

    try stdout.writeByte('\n');

    const password = try getPassword(gpa, stdout, stdin);
    defer {
        std.crypto.secureZero(u8, password);
        gpa.free(password);
    }

    try stdout.writeByte('\n');

    if (drive_process) |*p| {
        var aw: Io.Writer.Allocating = .init(gpa);
        defer aw.deinit();

        var buf: [4096]u8 = undefined;
        var reader = p.stderr.?.reader(io, &buf);

        _ = try reader.interface.streamRemaining(&aw.writer);

        const term = try p.wait(io);

        if (term != .exited or term.exited != 0) {
            logErr(io, aw.written());
            return error.DrivePartitionFailed;
        }
    }

    const host = try getHostInfo(io, gpa, stdout, stdin, &shell_opts);
    defer gpa.free(host);

    var install = try std.process.spawn(io, .{
        .argv = &.{
            "nixos-install",
            "--flake",
            host,
            "--no-channel-copy",
        },
        .cwd = .{ .dir = conf_dir },
        .stdin = .pipe,
    });

    for (0..2) |_| try install.stdin.?.writeStreamingAll(io, password);

    const term = try install.wait(io);

    if (term != .exited or term.exited != 0) {
        std.log.err("build failed, please try again", .{});
        return 1;
    }

    try stdout.writeAll("build complete, you may reboot\n");
    try stdout.flush();

    const dotfiles: Io.Dir = try .createDirPathOpen(.cwd(), io, "/mnt/home/lioma/dotfiles", .{
        .open_options = .{ .iterate = true }, // setOwner requires iterate
    });
    defer dotfiles.close(io);

    dotfiles.setOwner(io, 1000, 100) catch {
        std.log.warn("failed to set owner for directory 'dotfiles'", .{});
    };

    try copyDir(io, gpa, conf_dir, dotfiles);

    std.log.info("TODO: fix this hack", .{});
    var chown = std.process.spawn(io, .{
        .argv = &.{ "chown", "-R", "lioma", "/mnt/home/lioma/dotfiles" },
    }) catch {
        return 0;
    };
    _ = chown.wait(io) catch {};

    return 0;
}

const std = @import("std");
const builtin = @import("builtin");
const Io = std.Io;
const Child = std.process.Child;
const SpawnOptions = std.process.SpawnOptions;
