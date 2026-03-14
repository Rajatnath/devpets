const std = @import("std");
const profile = @import("../storage/profile.zig");

pub fn run(allocator: std.mem.Allocator) !void {
    var prof = (try profile.load(allocator)) orelse profile.Profile{};

    if (prof.created_at == 0) {
        prof.created_at = std.time.timestamp();
        try profile.save(allocator, prof);
    }

    const next_xp = profile.xpForNextStage(prof.stage);

    std.debug.print(
        \\
        \\ +-------------------------------------------+
        \\ |             🥚 DEVPET                     |
        \\ |                                           |
        \\ |              (  O  )                      |
        \\ |                                           |
        \\ |          Hatching Soon...                  |
        \\ |                                           |
        \\ |   Stage: {s:<10}                      |
        \\ |   XP: {d} / {d}                           |
        \\ |                                           |
        \\ |   Tip: Make commits to gain XP            |
        \\ +-------------------------------------------+
        \\
        \\
    , .{ profile.formatStage(prof.stage), prof.xp, next_xp });

    // TODO: Replace with TUI rendering loop (Task 2)
    std.debug.print("  TUI mode coming soon. Press Ctrl+C to exit.\n\n", .{});
}

pub fn status(allocator: std.mem.Allocator) !void {
    const prof = (try profile.load(allocator)) orelse {
        std.debug.print(
            \\
            \\  No pet found! Run 'devpet run' to start.
            \\
            \\
        , .{});
        return;
    };

    const next_xp = profile.xpForNextStage(prof.stage);
    const shiny_str: []const u8 = if (prof.shiny) " ✨ SHINY ✨" else "";

    std.debug.print(
        \\
        \\  🐾 DevPet Status
        \\  ─────────────────────
        \\  Species:  {s}{s}
        \\  Stage:    {s}
        \\  XP:       {d} / {d}
        \\  Commits:  {d}
        \\
        \\
    , .{
        profile.formatSpecies(prof.species),
        shiny_str,
        profile.formatStage(prof.stage),
        prof.xp,
        next_xp,
        prof.total_commits,
    });
}

pub fn addXp(allocator: std.mem.Allocator, amount: u32) !void {
    var prof = (try profile.load(allocator)) orelse profile.Profile{};

    prof.xp += amount;
    std.debug.print("\n  ✅ Added {d} XP! Total: {d}\n\n", .{ amount, prof.xp });

    // Check evolution threshold
    const threshold = profile.xpForNextStage(prof.stage);
    if (threshold > 0 and prof.xp >= threshold) {
        switch (prof.stage) {
            .egg => {
                prof.stage = .baby;
                // Assign random species
                const rand = std.crypto.random;
                const species_idx = rand.intRangeAtMost(u8, 0, 2);
                prof.species = switch (species_idx) {
                    0 => .ground_crocodile,
                    1 => .grass_owl,
                    2 => .ice_fox,
                    else => .grass_owl,
                };
                // 5% shiny chance
                prof.shiny = (rand.intRangeAtMost(u8, 1, 100) <= 5);

                const shiny_msg: []const u8 = if (prof.shiny) " ✨ IT'S SHINY! ✨" else "";
                std.debug.print("  🎉 EGG HATCHED! Meet your {s}!{s}\n\n", .{
                    profile.formatSpecies(prof.species),
                    shiny_msg,
                });
            },
            .baby => {
                prof.stage = .middle;
                std.debug.print("  🎉 Your pet evolved to Middle stage!\n\n", .{});
            },
            .middle => {
                prof.stage = .final_form;
                std.debug.print("  🎉 Your pet reached its FINAL FORM!\n\n", .{});
            },
            .final_form => {},
        }
    }

    try profile.save(allocator, prof);
}

pub fn reset(allocator: std.mem.Allocator) !void {
    try profile.delete(allocator);
    std.debug.print(
        \\
        \\  🗑️  Pet data has been reset.
        \\  Run 'devpet run' to start fresh!
        \\
        \\
    , .{});
}
