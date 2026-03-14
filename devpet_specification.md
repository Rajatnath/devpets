# DevPet

A terminal-based virtual developer companion that evolves based on real coding activity.

DevPet is a TUI (Terminal User Interface) application that lives inside the terminal and reacts to developer actions such as commits, coding sessions, and project activity.

Inspired by Tamagotchi-style progression, DevPet replaces manual care with **developer productivity signals**.

---

# Core Concept

Run:

```
devpet run
```

A coding egg appears inside the terminal.

As the developer writes code and makes commits, the egg gains XP and eventually hatches into a DevPet.

Progression:

```
Egg → Baby DevPet → Middle Evolution → Final Evolution
```

The Egg is a waiting state. The actual creature has **three evolution stages**.

---

# Key Features

- Terminal-based TUI interface
- ASCII / pixel styled creature
- Three evolution stages
- XP system based on developer activity
- Git integration
- Autonomous pet movement
- Pet personalities (Nature system)
- Abilities unlocked through evolution
- Random shiny rarity
- Idle animations and reactions
- Persistent pet data
- Lightweight CLI tool

---

# Evolution System

DevPet evolves through three main stages.

| Stage | Name | Description |
|------|------|-------------|
| 1 | Baby | Newly hatched pet |
| 2 | Middle | Larger evolved form |
| 3 | Final | Fully evolved DevPet |

XP thresholds example:

| Stage | XP Required |
|------|--------------|
| Egg | 0 |
| Baby | 100 |
| Middle | 500 |
| Final | 2000 |

---

# Rarity System

When the egg hatches, the pet has a chance to become **Shiny**.

Example probabilities:

Normal: 95%
Shiny: 5%

Shiny pets feature:

- Alternate colors
- Sparkle animation
- Special UI indicator

Example indicator:

```
✨ SHINY DEV PET ✨
```

Shiny status must persist in saved profile data.

---

# XP System

XP is gained through developer actions.

| Action | XP |
|------|----|
| Git commit | +10 |
| Pull request merged | +50 |
| Issue closed | +20 |
| 100 lines added | +5 |
| Coding streak day | +30 |

XP accumulates across sessions.

---

# Git Integration

DevPet monitors Git activity.

Primary method:

```
git log
git diff --stat
git rev-list
```

Example commit detection:

```
git log --since=1h
```

Optional Git hook:

```
.git/hooks/post-commit
```

Hook executes:

```
devpet add-xp 10
```

---

# Terminal UI Layout

Example UI:

```
+-----------------------------------+
|             DEVPET                |
|                                   |
|            /\_/\                  |
|           ( o.o )                 |
|            > ^ <                  |
|                                   |
| Stage: Baby                       |
| XP: 45 / 100                      |
| Mood: Curious                     |
|                                   |
| Tip: Make commits to gain XP      |
+-----------------------------------+
```

---

# Egg State

Initial state before the pet hatches.

```
+-----------------------------------+
|            CODING EGG             |
|                                   |
|             (  O  )               |
|                                   |
|          Hatching Soon...         |
|                                   |
|           XP: 0 / 100             |
+-----------------------------------+
```

---

# Hatching Event

When XP threshold is reached:

```
EGG HATCHED!
Meet your DevPet!
```

Baby DevPet appears.

---

# Nature System

Each pet has a **Nature**.

Nature determines personality and behavior.

Example natures:

| Nature | Behavior |
|------|----------|
| Curious | Moves frequently |
| Calm | Slow movement |
| Energetic | Jumps often |
| Lazy | Sleeps more |
| Playful | Performs random animations |

Nature may be randomly assigned or inferred from coding behavior.

---

# Coding-Based Nature (Optional)

Example mapping:

| Developer Behavior | Nature |
|--------------------|--------|
| many commits | disciplined |
| long sessions | focused |
| many comments | thoughtful |
| chaotic commits | chaotic |

---

# Abilities System

Abilities unlock with evolution.

Abilities trigger animations during developer actions.

| Ability | Trigger |
|--------|---------|
| Commit Dance | commit detected |
| Bug Smash | error fixed |
| Merge Celebration | PR merge |

Example animation:

```
( ^_^ )/
```

---

# Autonomous Movement

DevPet moves freely inside the terminal canvas.

Movement types:

- walk left
- walk right
- jump
- sit
- sleep
- idle

Movement updates every 300–800 ms.

Pet must stay within terminal bounds.

---

# Idle Behavior

If the user stops coding, the pet performs idle actions.

Examples:

- sleeping
- looking around
- sitting

Example:

```
( -.- ) zZ
```

Idle triggers after ~2 minutes inactivity.

---

# Developer Interaction Reactions

DevPet reacts to developer activity.

| Event | Reaction |
|------|----------|
| typing | excitement |
| commit | celebration |
| error | bug attack animation |

Example commit reaction:

```
( ^o^ )/
```

---

# Happiness System

Pet happiness increases with coding activity.

| Event | Happiness |
|------|-----------|
| commit | +5 |
| long session | +10 |
| idle long time | -5 |

Happiness affects behavior.

---

# Random Events

Occasional fun actions.

Examples:

- chasing a bug
- spinning
- waving

Probability example:

5% chance every 10 seconds.

---

# Data Persistence

Pet data stored locally.

Directory:

```
~/.devpet/
```

Files:

```
profile.json
stats.json
config.json
```

Example profile:

```
{
 "stage": "baby",
 "xp": 45,
 "shiny": false,
 "nature": "curious",
 "ability": "commit_dance",
 "happiness": 60
}
```

---

# CLI Commands

Run DevPet

```
devpet run
```

Show status

```
devpet status
```

Add XP

```
devpet add-xp 10
```

Reset pet

```
devpet reset
```

---

# Rendering Loop

Example main loop:

```
while running:
 detect developer activity
 update pet state
 update pet position
 draw UI
 draw pet
 sleep(100ms)
```

---

# Suggested Libraries

Preferred Zig libraries:

- vaxis
- tui.zig

Alternative:

- ncurses (via C interop)

---

# Project Architecture

```
devpet/
 ├── main.zig
 ├── cli/
 │    └── commands.zig
 ├── ui/
 │    ├── renderer.zig
 │    └── layout.zig
 ├── pet/
 │    ├── pet.zig
 │    ├── evolution.zig
 │    └── behavior.zig
 ├── git/
 │    └── tracker.zig
 ├── storage/
 │    └── profile.zig
```

---

# MVP Scope

Initial version should include:

- CLI command
- Egg stage
- Hatching
- Baby pet
- XP system
- Git commit detection
- Random shiny chance
- Pet movement
- Persistent profile

Estimated code size:

500–1000 lines.

---

# Performance Goals

Binary size:

<10MB

Memory usage:

<50MB

CPU usage minimal.

---

# Long-Term Ideas

Future improvements:

- achievements
- multiplayer leaderboards
- pet customization
- environment themes

---

# Project Goal

DevPet should feel like a **living coding companion inside the terminal**.

It should:

- react to coding
- move around
- evolve
- feel personal

The goal is to create a **fun CLI tool developers enjoy running while coding**.

