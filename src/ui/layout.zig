const std = @import("std");
const vaxis = @import("vaxis");
const Profile = @import("../storage/profile.zig").Profile;
const profile_mod = @import("../storage/profile.zig");

pub fn draw(win: vaxis.Window, prof: Profile) void {
    // Main bordered window
    const main_win = win.child(.{
        .border = .{
            .where = .all,
            .style = .{ .fg = .{ .index = 2 } }, // Green border
        },
    });

    // Draw Title
    const title = " DEVPET ";
    const title_col = @max(0, @divTrunc(@as(i32, main_win.width), 2) - @divTrunc(@as(i32, title.len), 2));
    _ = win.printSegment(.{
        .text = title,
        .style = .{ .bold = true, .fg = .{ .index = 3 } }, // Yellow bold
    }, .{
        .col_offset = @intCast(title_col),
        .row_offset = 0,
    });

    // Status bar at the top
    var buf: [256]u8 = undefined;
    const species_name = profile_mod.formatSpecies(prof.species);
    const stage_name = profile_mod.formatStage(prof.stage);
    const xp_target = profile_mod.xpForNextStage(prof.stage);
    
    // Line 1: Species and Stage
    const line1 = std.fmt.bufPrint(&buf, " {s} - {s}{s} ", .{
        species_name,
        stage_name,
        if (prof.shiny) " (✨ SHINY)" else "",
    }) catch " Status Error ";

    _ = main_win.printSegment(.{
        .text = line1,
        .style = .{ .bold = true },
    }, .{
        .col_offset = 2,
        .row_offset = 1,
    });

    // Line 2: XP and Commits
    var buf2: [256]u8 = undefined;
    const line2 = std.fmt.bufPrint(&buf2, " XP: {d}/{d} | Commits: {d} | Mood: {d} ", .{
        prof.xp,
        xp_target,
        prof.total_commits,
        prof.happiness,
    }) catch " Stats Error ";

    _ = main_win.printSegment(.{
        .text = line2,
        .style = .{ .fg = .{ .index = 6 } }, // Cyan
    }, .{
        .col_offset = 2,
        .row_offset = 2,
    });

    // Separator
    const sep_win = main_win.child(.{
        .y_off = 3,
        .height = 1,
    });
    for (0..sep_win.width) |c| {
        sep_win.writeCell(@intCast(c), 0, .{
            .char = .{ .grapheme = "─", .width = 1 },
            .style = .{ .fg = .{ .index = 2 } }, // Green
        });
    }

    // Sprite drawing area
    const sprite_win = main_win.child(.{
        .x_off = 2,
        .y_off = 5,
    });

    // Placeholder sprite for now
    drawPlaceholderSprite(sprite_win, prof);
}

const registry = @import("../sprite/registry.zig");

fn drawPlaceholderSprite(win: vaxis.Window, prof: Profile) void {
    const sprite = registry.getSpriteForProfile(prof);

    var iter = std.mem.splitScalar(u8, sprite, '\n');
    var max_width: usize = 0;
    var line_count: usize = 0;

    // First pass to determine sprite dimensions to center it
    while (iter.next()) |line| {
        max_width = @max(max_width, line.len);
        line_count += 1;
    }

    // Reset iterator for drawing
    iter = std.mem.splitScalar(u8, sprite, '\n');

    // Calculate centering offsets
    const sprite_col = @max(0, @divTrunc(@as(i32, @intCast(win.width)), 2) - @divTrunc(@as(i32, @intCast(max_width)), 2));
    const sprite_row = @max(0, @divTrunc(@as(i32, @intCast(win.height)), 2) - @divTrunc(@as(i32, @intCast(line_count)), 2) - 1); // Slight offset above the middle

    var act_row: u16 = @intCast(sprite_row);

    // Draw lines
    while (iter.next()) |line| {
        if (line.len == 0) continue;
        
        _ = win.printSegment(.{
            .text = line,
            .style = .{ .fg = .{ .index = 5 } }, // Magenta
        }, .{
            .col_offset = @intCast(sprite_col),
            .row_offset = act_row,
        });
        act_row += 1;
    }

    const help_msg = "Terminal UI Active. Press 'q' to exit.";
    const help_col = @max(0, @divTrunc(@as(i32, win.width), 2) - @divTrunc(@as(i32, help_msg.len), 2));
    _ = win.printSegment(.{
        .text = help_msg,
        .style = .{ .dim = true },
    }, .{
        .col_offset = @intCast(help_col),
        .row_offset = @intCast(win.height - 2), // Near bottom
    });
}
