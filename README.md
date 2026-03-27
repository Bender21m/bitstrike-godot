# ₿itStrike — Godot Edition

Counter-Strike meets Bitcoin. Built with Godot 4.3.

## Setup
1. Download [Godot 4.3](https://godotengine.org/download)
2. Open this project folder in Godot
3. Press F5 to run

## Project Structure
```
scenes/          - Godot scene files (.tscn)
  main.tscn      - Main game scene
  maps/          - Map scenes
scripts/         - GDScript files
  player.gd      - FPS controller + shooting + economy
  enemy.gd       - Enemy AI + types + damage
  game_state.gd  - Global state (autoload)
assets/
  models/        - GLTF/GLB character + weapon models
  textures/      - Materials and textures
  sounds/        - Audio files
  maps/          - Map geometry
```

## Controls
- WASD: Move
- Mouse: Look
- Left Click: Shoot
- R: Reload
- 1/2/3: Switch weapons
- Shift: Sprint
- B: Buy menu

## Enemy Types
- 🏦 Evil Banker — grey suit, red tie
- 🪙 Shitcoiner — purple glow, gold chain
- 🐻 FUD Bear — spreading FUD
- 🟢 Roger Ver — green BCH suit, sometimes runs away
- 🔵 Adam Back — glasses, Hashcash armor, tanky
- 👔 Fed Chairman — BOSS, money printer
