const std = @import("std");

pub const Species = enum {
    ground_crocodile,
    grass_owl,
    ice_fox,
    none,
};

pub const Stage = enum {
    egg,
    baby,
    middle,
    final_form,
};

pub const Profile = struct {
    stage: Stage = .egg,
    xp: u32 = 0,
    species: Species = .none,
    shiny: bool = false,
    happiness: i32 = 50,
    total_commits: u32 = 0,
    created_at: i64 = 0,
};

const DEVPET_DIR = ".devpet";
const PROFILE_FILE = "profile.json";

fn getProfileDir(allocator: std.mem.Allocator) ![]const u8 {
    // Use XDG_DATA_HOME, HOME, or fall back to CWD
    if (std.process.getEnvVarOwned(allocator, "DEVPET_DATA_DIR")) |dir| {
        return dir;
    } else |_| {}

    if (std.process.getEnvVarOwned(allocator, "HOME")) |home| {
        defer allocator.free(home);
        return std.fs.path.join(allocator, &.{ home, DEVPET_DIR });
    } else |_| {}

    // Fallback: use CWD
    return allocator.dupe(u8, DEVPET_DIR);
}

fn getProfilePath(allocator: std.mem.Allocator) ![]const u8 {
    const dir = try getProfileDir(allocator);
    defer allocator.free(dir);
    return std.fs.path.join(allocator, &.{ dir, PROFILE_FILE });
}

pub fn load(allocator: std.mem.Allocator) !?Profile {
    const path = try getProfilePath(allocator);
    defer allocator.free(path);

    const file = std.fs.openFileAbsolute(path, .{}) catch |err| {
        if (err == error.FileNotFound) return null;
        return err;
    };
    defer file.close();

    const content = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(content);

    const parsed = std.json.parseFromSlice(Profile, allocator, content, .{
        .ignore_unknown_fields = true,
    }) catch {
        return null;
    };
    defer parsed.deinit();

    return parsed.value;
}

pub fn save(allocator: std.mem.Allocator, prof: Profile) !void {
    const dir_path = try getProfileDir(allocator);
    defer allocator.free(dir_path);

    std.fs.makeDirAbsolute(dir_path) catch |err| {
        if (err != error.PathAlreadyExists) return err;
    };

    const path = try getProfilePath(allocator);
    defer allocator.free(path);

    const file = try std.fs.createFileAbsolute(path, .{});
    defer file.close();

    // Format JSON into buffer, then write all at once
    var buf: [2048]u8 = undefined;
    const json = std.fmt.bufPrint(&buf,
        \\{{
        \\  "stage": "{s}",
        \\  "xp": {d},
        \\  "species": "{s}",
        \\  "shiny": {s},
        \\  "happiness": {d},
        \\  "total_commits": {d},
        \\  "created_at": {d}
        \\}}
        \\
    , .{
        @tagName(prof.stage),
        prof.xp,
        @tagName(prof.species),
        if (prof.shiny) "true" else "false",
        prof.happiness,
        prof.total_commits,
        prof.created_at,
    }) catch return error.FormatError;

    try file.writeAll(json);
}

pub fn delete(allocator: std.mem.Allocator) !void {
    const path = try getProfilePath(allocator);
    defer allocator.free(path);

    std.fs.deleteFileAbsolute(path) catch |err| {
        if (err != error.FileNotFound) return err;
    };
}

pub fn formatStage(stage: Stage) []const u8 {
    return switch (stage) {
        .egg => "Egg",
        .baby => "Baby",
        .middle => "Middle",
        .final_form => "Final",
    };
}

pub fn formatSpecies(species: Species) []const u8 {
    return switch (species) {
        .ground_crocodile => "Ground Crocodile",
        .grass_owl => "Grass Owl",
        .ice_fox => "Ice Fox",
        .none => "Unknown",
    };
}

pub fn xpForNextStage(stage: Stage) u32 {
    return switch (stage) {
        .egg => 100,
        .baby => 500,
        .middle => 2000,
        .final_form => 0,
    };
}
