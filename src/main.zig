const std = @import("std");
const commands = @import("cli/commands.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        printUsage();
        return;
    }

    const cmd = args[1];

    if (std.mem.eql(u8, cmd, "run")) {
        try commands.run(allocator);
    } else if (std.mem.eql(u8, cmd, "status")) {
        try commands.status(allocator);
    } else if (std.mem.eql(u8, cmd, "add-xp")) {
        if (args.len < 3) {
            std.debug.print("Usage: devpet add-xp <amount>\n", .{});
            return;
        }
        const amount = std.fmt.parseInt(u32, args[2], 10) catch {
            std.debug.print("Error: '{s}' is not a valid number\n", .{args[2]});
            return;
        };
        try commands.addXp(allocator, amount);
    } else if (std.mem.eql(u8, cmd, "reset")) {
        try commands.reset(allocator);
    } else if (std.mem.eql(u8, cmd, "help") or std.mem.eql(u8, cmd, "--help") or std.mem.eql(u8, cmd, "-h")) {
        printUsage();
    } else {
        std.debug.print("Unknown command: '{s}'\n\n", .{cmd});
        printUsage();
    }
}

fn printUsage() void {
    const usage =
        \\
        \\  🥚 DevPet — Your Terminal Coding Companion
        \\
        \\  USAGE:
        \\    devpet <command> [options]
        \\
        \\  COMMANDS:
        \\    run              Launch DevPet TUI
        \\    status           Show pet status
        \\    add-xp <amount>  Manually add XP
        \\    reset            Reset pet data
        \\    help             Show this message
        \\
    ;
    std.debug.print("{s}\n", .{usage});
}
