# DevPet V1 — Implementation Plan

## Goal

Build the MVP of DevPet: a Zig-based TUI virtual pet that hatches from an egg, evolves, and gains XP from real Git activity. The pet is rendered as 16×16 pixel sprites using colored terminal blocks.

## Project Type

**CLI / TUI Application** — Zig language, no web/mobile.

## Success Criteria

- `devpet run` launches a TUI with a rendered pixel-art egg
- Making git commits causes XP gain and eventual hatching
- One of three species is randomly selected at hatch (5% shiny chance)
- Pet moves autonomously within the terminal canvas
- Pet data persists across sessions in `~/.devpet/`
- `devpet status`, `devpet add-xp`, `devpet reset` all work
- Binary is <10MB, memory <50MB

## Tech Stack

| Technology | Role | Rationale |
|-----------|------|-----------|
| **Zig** | Language | Small binaries, cross-compilation, C interop |
| **libvaxis** | TUI library | Zig-native terminal rendering (primary) |
| **tui.zig** | TUI fallback | Alternative if libvaxis doesn't fit |
| **zig build** | Build system | Built-in, zero external deps |

## File Structure

```
devpet/
├── build.zig
├── build.zig.zon              # dependency manifest (libvaxis)
├── src/
│   ├── main.zig               # entry point, CLI arg parsing
│   ├── cli/
│   │   └── commands.zig       # run, status, add-xp, reset
│   ├── ui/
│   │   ├── renderer.zig       # terminal rendering, color mapping
│   │   └── layout.zig         # UI frame, status bar, borders
│   ├── pet/
│   │   ├── pet.zig            # pet state struct (species, stage, xp, shiny)
│   │   ├── evolution.zig      # XP thresholds, stage transitions
│   │   ├── movement.zig       # autonomous movement logic
│   │   └── species.zig        # species definitions, color palettes
│   ├── sprite/
│   │   ├── loader.zig         # parse .txt sprite grid files
│   │   ├── animation.zig      # frame cycling (120ms interval)
│   │   └── render.zig         # convert sprite chars → colored █ blocks
│   ├── git/
│   │   └── tracker.zig        # git log polling, commit detection
│   ├── xp/
│   │   └── xp.zig             # XP calculations, streak tracking
│   └── storage/
│       └── profile.zig        # JSON read/write to ~/.devpet/
├── sprites/
│   ├── egg/
│   │   ├── idle_1.txt
│   │   └── idle_2.txt
│   ├── ground_crocodile/
│   │   ├── baby_idle_1.txt
│   │   └── baby_idle_2.txt
│   ├── grass_owl/
│   │   ├── baby_idle_1.txt
│   │   └── baby_idle_2.txt
│   └── ice_fox/
│       ├── baby_idle_1.txt
│       └── baby_idle_2.txt
└── devpet_specification.md
```

## Tasks

Tasks follow the **spec-defined development priority order**.

### Task 1: Project Scaffold & CLI Commands
**Files:** `build.zig`, `build.zig.zon`, `src/main.zig`, `src/cli/commands.zig`

- [ ] Initialize Zig project with `zig init`
- [ ] Add libvaxis as dependency in `build.zig.zon`
- [ ] Implement CLI arg parsing: `run`, `status`, `add-xp <n>`, `reset`
- [ ] `devpet run` prints placeholder text for now

**Verify:** `zig build` succeeds; `./zig-out/bin/devpet run` prints placeholder; `devpet status` prints "No pet found"

---

### Task 2: Terminal UI Window
**Files:** `src/ui/layout.zig`, `src/ui/renderer.zig`

- [ ] Create bordered TUI frame using libvaxis
- [ ] Render status bar (species name, stage, XP, mood)
- [ ] Handle terminal resize
- [ ] Implement clean exit on `q` / `Ctrl+C`
- [ ] Main render loop at ~100ms tick

**Verify:** `devpet run` opens a bordered TUI window showing placeholder text; resizing terminal adapts the frame; `q` exits cleanly

---

### Task 3: Sprite Renderer
**Files:** `src/sprite/loader.zig`, `src/sprite/render.zig`, `sprites/egg/*.txt`

- [ ] Parse 16×16 `.txt` grid files (`.` = transparent, letter = color)
- [ ] Map color characters → ANSI terminal colors (G→green, B→blue, R→red, W→white, K→black, etc.)
- [ ] Render sprite as `█` blocks inside the TUI frame
- [ ] Create 2 egg sprite frames (`egg/idle_1.txt`, `egg/idle_2.txt`)

**Verify:** `devpet run` renders a colored egg sprite in the terminal window

---

### Task 4: Animation System & Pet Movement
**Files:** `src/sprite/animation.zig`, `src/pet/movement.zig`

- [ ] Implement frame cycling (frame1 ↔ frame2 at 120ms)
- [ ] Pet position tracking (`pet_x`, `pet_y`)
- [ ] Random movement: `pet_x += random(-1, 1)`, `pet_y += random(-1, 1)` every 300–800ms
- [ ] Clamp position within terminal bounds
- [ ] Movement types: walk, hop, idle, sleep

**Verify:** Egg sprite animates between 2 frames; egg moves around inside the bordered area without going out of bounds

---

### Task 5: Git Activity Detection
**Files:** `src/git/tracker.zig`

- [ ] Run `git log --since="10 seconds ago"` via `std.process.Child`
- [ ] Parse output to count new commits
- [ ] Poll on a timer (every 10 seconds)
- [ ] Handle non-git directories gracefully (no crash)
- [ ] Detect `git diff --stat` for lines-added tracking

**Verify:** Make a git commit in a test repo; DevPet detects the commit within 10 seconds and logs it

---

### Task 6: XP System
**Files:** `src/xp/xp.zig`, `src/pet/pet.zig`

- [ ] XP struct tracking total XP, streak days
- [ ] XP awards: commit +10, 100 lines added +5, streak day +30
- [ ] `devpet add-xp <n>` manually adds XP
- [ ] XP display in status bar updates in real time
- [ ] Link git tracker events → XP awards

**Verify:** `devpet add-xp 50` increases XP; making a git commit while running adds +10 XP visible in UI

---

### Task 7: Hatching System
**Files:** `src/pet/evolution.zig`

- [ ] Egg hatches at 100 XP threshold
- [ ] Hatching animation / message ("EGG HATCHED! Meet your DevPet!")
- [ ] Transition from egg sprite → baby pet sprite

**Verify:** Start with XP=95; make a commit (+10); egg hatches and baby sprite appears

---

### Task 8: Species Selection
**Files:** `src/pet/species.zig`, `sprites/ground_crocodile/*.txt`, `sprites/grass_owl/*.txt`, `sprites/ice_fox/*.txt`

- [ ] Define 3 species with color palettes
- [ ] Random selection at hatch: `ground_crocodile`, `grass_owl`, `ice_fox`
- [ ] Create baby_idle_1.txt + baby_idle_2.txt for each species (6 sprite files)
- [ ] Load correct sprite set based on selected species

**Verify:** Reset pet multiple times; different species appear (test randomness). Each species renders with its correct color palette

---

### Task 9: Shiny System
**Files:** `src/pet/pet.zig`, `src/pet/species.zig`

- [ ] 5% chance at hatch to become shiny
- [ ] Shiny uses alternate color palette per species
- [ ] `✨ SHINY ✨` indicator in status bar
- [ ] Shiny status persists in profile

**Verify:** Force shiny=true in profile; verify alternate colors and ✨ indicator appear

---

### Task 10: Data Persistence & Profile
**Files:** `src/storage/profile.zig`

- [ ] Create `~/.devpet/` directory if not exists
- [ ] Save/load `profile.json` (stage, xp, species, shiny, nature, happiness)
- [ ] Auto-save on XP change, evolution, hatch
- [ ] `devpet status` reads from profile and prints summary
- [ ] `devpet reset` deletes profile and confirms

**Verify:** Run DevPet, gain XP, quit; re-run and verify XP persists. `devpet reset` wipes data. `devpet status` shows correct info

---

## Done When

- [ ] `devpet run` shows egg → gains XP from git commits → hatches into random species → moves around
- [ ] `devpet status` / `add-xp` / `reset` all work
- [ ] Data persists in `~/.devpet/profile.json`
- [ ] Binary builds clean on macOS with `zig build`

## Phase X: Verification Checklist

- [ ] `zig build` — no errors, no warnings
- [ ] Binary size < 10MB
- [ ] Memory usage < 50MB (check via Activity Monitor or `top`)
- [ ] `devpet run` → smoke test full flow: egg → commit → hatch → movement → quit → re-run → data persists
- [ ] `devpet reset` → `devpet run` → fresh egg appears
- [ ] Test in standard terminal (80×24 minimum) — no rendering glitches
- [ ] Cross-compile check: `zig build -Dtarget=x86_64-linux` succeeds

## Notes

- **V2 features deferred:** Nature system, Abilities, Happiness system, Random events, Coding-style personality, Middle/Final evolution sprites
- **Sprite files are manual:** Created with pixel editor, not generated by code
- **libvaxis availability:** If libvaxis has compatibility issues, fallback to tui.zig. Evaluate in Task 2
