# Project Planning Clarifications (Answers)

This section answers the planning questions raised before creating the implementation roadmap (`devpet-app.md`). These decisions define the **initial development constraints for DevPet V1**.

---

## 1. Tech Stack Confirmation

**Decision:** DevPet will be built using **Zig**.

Reasoning:

- Produces **very small static binaries** suitable for CLI tools
- Excellent **cross-compilation support**
- Strong **C interoperability** if we need to fall back to libraries like `ncurses`
- Fits the goal of making DevPet a **lightweight developer utility**

Preferred libraries for the terminal UI:

1. **libvaxis** (primary choice)
2. **tui.zig** (fallback option)
3. **ncurses via C interop** (last resort if needed)

Alternative stacks like Rust (`ratatui`) or Go (`bubbletea`) were considered but **Zig remains the chosen language for the project**.

---

## 2. Scope for V1

**Decision:** Build **MVP first**, then expand to the full feature set.

The initial implementation should focus only on the core gameplay loop.

### V1 MVP Scope

- CLI commands
- Terminal UI window
- Egg stage
- Hatching system
- Baby pet stage
- Random species selection
- Random shiny chance
- Sprite renderer
- Basic animation system
- Autonomous pet movement
- Git commit detection
- XP system
- Persistent profile storage

### Features Deferred to V2

The following systems will be implemented later:

- Nature / personality system
- Abilities
- Happiness system
- Random behavioral events
- Coding-style based personality
- Multiple evolution sprite sets

This keeps the first release **small, stable, and testable**.

---

## 3. Git Integration Depth

**Decision:** Use **Git polling only for V1**.

The application will periodically check repository activity using Git CLI commands.

Example approach:

```
git log --since="10 seconds ago"
```

This avoids modifying user repositories.

### Git Hooks

Git hooks may be added in a future version as an **optional advanced feature**.

---

## 4. Sprite / Art Source

DevPet will **not use ASCII art animals**.

Instead, the game uses **16×16 pixel RPG-style sprites rendered in the terminal using colored blocks**.

Sprite assets will be created manually using a pixel editor such as:

- Piskel
- Aseprite
- Lospec Pixel Editor

The engine will load sprites from text-based pixel grid files.

Example sprite grid format:

```
....GGGG....
...GGGGGG...
..GG..GGGG..
..GGGGGGGG..
...GGGGGG...
....GGGG....
```

Legend example:

```
. = transparent
G = green pixel
B = blue pixel
R = red pixel
```

These characters are converted into colored terminal blocks by the renderer.

---

## 5. Distribution Strategy

**Initial distribution method:** simple binary releases.

DevPet will be distributed via:

- GitHub Releases
- Precompiled binaries

Example files:

```
devpet-linux
devpet-macos
devpet-windows
```

Users will simply download and run the binary.

### Future Installation Methods

Later releases may support:

- Homebrew
- AUR (Arch Linux)
- Nix
- Scoop (Windows)

For now the focus is on **shipping the first working binary quickly**.

---

# DevPet — Additional Design Updates

This document extends the previous DevPet specification with the latest design decisions discussed after the initial documentation.

These updates define:

- Final pet species
- Pixel-art sprite system
- Terminal rendering strategy
- Sprite asset structure
- Animation system
- Pet movement behavior
- Implementation roadmap for the sprite engine

---

# Final Pet Species

The egg will hatch into **one of three pets randomly**.

These are the final species for DevPet V1.

| Species | Theme | Description |
|-------|-------|-------------|
| ground_crocodile | Earth | A sturdy crocodile creature representing ground power |
| grass_owl | Nature | A watchful owl representing grass/nature element |
| ice_fox | Ice | A magical fox representing ice/water energy |

Species is determined when the egg hatches.

Example logic:

```
species_list = [ground_crocodile, grass_owl, ice_fox]
selected_species = random_choice(species_list)
```

---

# Evolution System

Each pet has **three evolution stages**.

| Stage | Description |
|------|-------------|
| baby | First hatched form |
| middle | Second evolution |
| final | Final evolved form |

XP thresholds example:

```
baby → 100 XP
middle → 500 XP
final → 2000 XP
```

---

# Pixel Sprite System

DevPet will **NOT use ASCII art characters**.

Instead it uses **pixel-art sprites rendered inside the terminal**.

Sprites are drawn using **colored terminal blocks**.

Each pixel is rendered using:

```
█
```

with ANSI colors.

---

# Sprite Resolution

Recommended resolution for DevPet sprites:

```
16 × 16 pixels
```

This size works well in terminal environments.

---

# Sprite Storage Format

Sprites are stored as **pixel grid text files**.

Example sprite file:

```
................
....GGGG........
...GGGGGG.......
..GG..GGGG......
..GGGGGGGG......
...GGGGGG.......
....GGGG........
................
................
................
................
................
................
................
................
................
```

Legend example:

```
. → transparent
G → green pixel
B → blue pixel
R → red pixel
W → white pixel
K → black pixel
```

The renderer converts these characters into colored blocks.

---

# Sprite Asset Structure

Assets must follow this directory structure.

```
sprites/

   ground_crocodile/
      baby_idle_1.txt
      baby_idle_2.txt
      middle_idle_1.txt
      final_idle_1.txt

   grass_owl/
      baby_idle_1.txt
      baby_idle_2.txt
      middle_idle_1.txt
      final_idle_1.txt

   ice_fox/
      baby_idle_1.txt
      baby_idle_2.txt
      middle_idle_1.txt
      final_idle_1.txt
```

---

# Minimum Sprite Requirement (V1)

To keep development simple:

```
3 species
1 stage (baby)
2 animation frames
```

Total sprite files needed:

```
6 sprite files
```

More sprites can be added later.

---

# Animation System

Each pet has multiple animation frames.

Example:

```
baby_idle_1
baby_idle_2
```

Animation cycle:

```
frame1 → frame2 → frame1 → frame2
```

Frame switch interval:

```
120 ms
```

---

# Terminal Rendering Strategy

DevPet renders sprites by converting sprite characters into terminal colors.

Example mapping:

```
G → green block
B → blue block
R → red block
. → empty space
```

Rendering example:

```
██░░██
██████
██░░██
```

Each block represents one pixel.

---

# Pet Movement System

Pets move around inside the terminal UI area.

Coordinates:

```
pet_x
pet_y
```

Movement logic example:

```
pet_x += random(-1, 1)
pet_y += random(-1, 1)
```

Movement interval:

```
300–800 ms
```

Movement types:

- walk
- hop
- idle
- sleep

---

# Terminal UI Layout

Example DevPet screen:

```
+------------------------------------------------+
|                                                |
|      ████                                      |
|     █    █                                     |
|     █ ██ █      grass_owl (baby)               |
|      ████                                      |
|                                                |
| XP: 45 / 100                                   |
| Mood: Curious                                  |
|                                                |
+------------------------------------------------+
```

The pet moves freely inside the boxed area.

---

# Shiny Variant

When the egg hatches there is a chance the pet becomes **Shiny**.

Probability example:

```
normal → 95%
shiny → 5%
```

Shiny variants use alternate color palettes and may include sparkle effects.

---

# Color Palettes

Each species uses its own palette.

### Ground Crocodile

```
dark green
olive green
brown
beige
```

### Grass Owl

```
light green
forest green
cream
brown
```

### Ice Fox

```
white
light blue
cyan
blue
```

---

# Development Priority

Development should follow this order:

1. CLI commands
2. Terminal UI rendering
3. Sprite renderer
4. Pet movement
5. Git activity detection
6. XP system
7. Hatching system
8. Species selection
9. Shiny system
10. Evolution system

---

# Immediate Next Steps

To begin development:

1. Create **baby sprites** for the three species
2. Build the sprite rendering engine
3. Implement random species selection
4. Implement terminal movement system
5. Implement XP tracking

Once these are complete, DevPet will have its first playable prototype.

---

# Design Goal

DevPet should look like a **tiny RPG creature walking inside the terminal**.

The experience should feel:

- playful
- responsive
- alive
- rewarding for developers who code frequently

The terminal should feel like a **mini pixel RPG world for your coding companion**.

