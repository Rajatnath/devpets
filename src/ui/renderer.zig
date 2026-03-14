const std = @import("std");
const vaxis = @import("vaxis");
const Profile = @import("../storage/profile.zig").Profile;
const layout = @import("layout.zig");

// Define custom event type for our application loop
pub const Event = union(enum) {
    key_press: vaxis.Key,
    key_release: vaxis.Key,
    mouse: vaxis.Mouse,
    mouse_leave,
    focus_in,
    focus_out,
    paste_start,
    paste_end,
    paste: []const u8,
    color_report: vaxis.Cell.Color.Report,
    color_scheme: vaxis.Cell.Color.Scheme,
    winsize: vaxis.Winsize,

    cap_kitty_keyboard,
    cap_kitty_graphics,
    cap_rgb,
    cap_sgr_pixels,
    cap_unicode,
    cap_da1,
    cap_color_scheme_updates,
    cap_multi_cursor,

    // App-specific event
    tick,
};

fn tickThread(loop: *vaxis.Loop(Event)) void {
    while (!loop.should_quit) {
        std.time.sleep(100 * std.time.ns_per_ms); // 100ms tick for animations
        if (!loop.tryPostEvent(.tick)) {
            // queue full, just drop the tick
        }
    }
}

pub fn run(allocator: std.mem.Allocator, profile: *Profile) !void {
    var tty = try vaxis.Tty.init(&.{});
    defer tty.deinit();

    var vx = try vaxis.init(allocator, .{});
    defer vx.deinit(allocator, tty.writer());

    var loop: vaxis.Loop(Event) = .{
        .tty = &tty,
        .vaxis = &vx,
    };
    try loop.init();

    try loop.start();
    defer loop.stop();

    // Spawn ticker thread
    const ticker = try std.Thread.spawn(.{}, tickThread, .{&loop});
    defer ticker.join();

    try vx.enterAltScreen(tty.writer());
    try vx.queryTerminal(tty.writer(), 1 * std.time.ns_per_ms); // Block briefly for queries

    // Initial render
    try vx.resize(allocator, tty.writer(), try vaxis.Tty.getWinsize(tty.fd));
    vx.window().clear();
    layout.draw(vx.window(), profile.*);
    try vx.render(tty.writer());

    while (true) {
        const event = loop.nextEvent();
        switch (event) {
            .key_press => |key| {
                if (key.matches('c', .{ .ctrl = true }) or key.matches('q', .{})) {
                    break;
                }
            },
            .winsize => |ws| {
                try vx.resize(allocator, tty.writer(), ws);
            },
            .tick => {
                // Future: Animation updates
            },
            else => {},
        }

        const win = vx.window();
        win.clear();

        layout.draw(win, profile.*);

        try vx.render(tty.writer());
    }
}
