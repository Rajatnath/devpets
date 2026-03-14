const std = @import("std");
const Profile = @import("../storage/profile.zig").Profile;
const vaxis = @import("vaxis");

pub const StageSprites = struct {
    egg: []const u8 = 
        \\     .---.
        \\    /     \
        \\   |       |
        \\    \     /
        \\     '---'
    ,
    
    // Fallback base sprites
    baby: []const u8 = 
        \\   (\ /)
        \\   ( . .)
        \\   C(")(")
    ,
    middle: []const u8 = 
        \\    /\_/\
        \\   ( o.o )
        \\    > ^ <
    ,
    final_form: []const u8 = 
        \\     /\_/\
        \\    ( >.< )
        \\     >"<"
        \\    / _ \
    ,
};

// Ground Crocodile Species
pub const GroundCrocodile = StageSprites{
    .baby = 
        \\   _/\_
        \\  (o o )
        \\   \|/
    ,
    .middle = 
        \\   _/\__/\_
        \\  ( o  o  )
        \\  / \__/ \
    ,
    .final_form = 
        \\   _/\__/\__/\_
        \\  ( o   o     )
        \\  /  \_/     \
        \\  \____/  \__/
    ,
};

// Grass Owl Species
pub const GrassOwl = StageSprites{
    .baby = 
        \\   (o,o)
        \\   (   )
        \\   -"-"-
    ,
    .middle = 
        \\   ,___,
        \\   (O,O)
        \\   /)_(\
        \\   -"-"-
    ,
    .final_form = 
        \\    ___
        \\   (O,O)
        \\  /)___(\
        \\   /   \
        \\  -"---"-
    ,
};

// Ice Fox Species
pub const IceFox = StageSprites{
    .baby = 
        \\    /\_/\
        \\   ( ^.^ )
        \\     / \
    ,
    .middle = 
        \\    /\_/\
        \\   ( '.' )~
        \\   / | \
    ,
    .final_form = 
        \\    /\__/\
        \\   ( '  ' )~~
        \\   / |  | \   
        \\  /  |__|  \
    ,
};

pub fn getSpriteForProfile(prof: Profile) []const u8 {
    if (prof.stage == .egg) {
        const base = StageSprites{};
        return base.egg;
    }

    const sprites = switch (prof.species) {
        .none => StageSprites{}, // fallback for none
        .ground_crocodile => GroundCrocodile,
        .grass_owl => GrassOwl,
        .ice_fox => IceFox,
    };

    return switch (prof.stage) {
        .egg => sprites.egg,
        .baby => sprites.baby,
        .middle => sprites.middle,
        .final_form => sprites.final_form,
    };
}
