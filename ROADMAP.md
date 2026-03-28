# ₿itStrike — Decade Roadmap

## Year 1: Foundation (2026)

### Q2 2026 — Core Game ✅
- [x] Godot 4.3 engine setup + web export pipeline
- [x] Basic FPS controller (movement, look, collision, sprint, crouch, jump)
- [x] Scene generation system (headless)
- [x] Enemy spawning + AI (patrol, chase, flank, cover, attack, burst fire)
- [x] 5 weapons with viewmodels (Knife, AK-B7, Beagle, Sabot, M4-SAT)
- [x] Shooting with hit detection + damage + headshots (2x)
- [x] HUD (health, armor, sats, ammo, round info, stance, crosshair)
- [x] Buy menu between rounds (weapons, gear, grenades, ammo, utility)
- [x] 6 hand-crafted maps (Mining Facility, Silk Road, Citadel, Offshore, Vault, Trainyard)
- [x] Death/respawn system (REKT screen, sats penalty, tips, restart)
- [x] Sound effects (shoot, kill, hurt, headshot, reload, footstep, round start)
- [x] Particle effects (muzzle flash, blood splatter, bullet impacts, sparks)
- [x] Minimap/radar with enemy tracking
- [x] Kill streaks (Double Kill → Godlike → Whole Coiner)
- [x] Sats popup on kills
- [x] Damage indicators (direction + overlay)
- [x] WebGL context loss recovery
- [x] Main menu with map selection
- [x] Settings menu (sensitivity, volume, FOV, crosshair color)
- [x] Map rotation system (every 5 rounds)

### Q3 2026 — Characters & Polish
- [ ] Import Mixamo character models (rigged, animated)
- [ ] Walk/run/death/idle animations
- [x] 6 enemy types (Banker, Shitcoiner, Bear, Roger, Whale, Fed) + Satoshi boss
- [x] Unique enemy visuals (suits, accessories, colors, eyes, health bars)
- [x] Weapon pickup/drop system
- [x] Grenades (flashbang, BCash explosive, smoke)
- [x] Armor + helmet system (via buy menu)
- [x] Kill streaks ("DOUBLE KILL" → "WHOLE COINER!")
- [x] Scoreboard
- [x] Settings menu (sensitivity, volume, FOV, crosshair color)

### Q4 2026 — Maps & Content
- [ ] 21 unique maps with proper BSP-style geometry
- [ ] Map textures (brick, concrete, metal, wood)
- [ ] Skyboxes per map theme
- [ ] Destructible objects (crates, barrels)
- [ ] Map hazards (lava, electric fences)
- [ ] Satoshi unlockable character
- [ ] WEBFIVE soundtrack integration
- [ ] Sound propagation (footsteps through walls)
- [ ] Minimap

## Year 2: Multiplayer (2027)

### Q1 2027 — Netcode Foundation
- [ ] WebSocket server (Node.js or Rust)
- [ ] Client-server architecture
- [ ] Player synchronization
- [ ] Lag compensation + interpolation
- [ ] Server-authoritative hit detection

### Q2 2027 — Online Play
- [ ] Matchmaking system
- [ ] 5v5 competitive mode (Bitcoiners vs Fiat Maxis)
- [ ] Team selection screen
- [ ] Voice chat (WebRTC)
- [ ] Anti-cheat basics
- [ ] Server browser

### Q3-Q4 2027 — Ranked & Community
- [ ] ELO/ranking system
- [ ] Leaderboards
- [ ] Player profiles
- [ ] Replay system
- [ ] Spectator mode
- [ ] Community map submission

## Year 3: Bitcoin Integration (2028)

### Q1 2028 — Lightning Payments
- [ ] Lightning wallet integration (LNbits/NWC)
- [ ] Sats wagering on matches
- [ ] Entry fees for ranked (optional)
- [ ] Winner-takes-pot tournaments

### Q2 2028 — In-Game Economy
- [ ] Weapon skins (purchasable with sats)
- [ ] Character skins
- [ ] Skin marketplace (P2P, Lightning)
- [ ] Streaming sats to kill feed
- [ ] Bounty system (put sats on a player's head)

### Q3-Q4 2028 — Nostr Integration
- [ ] Login with Nostr (npub)
- [ ] Game events published to Nostr relays
- [ ] Live match spectating via Nostr
- [ ] Clip sharing (NIP-94 media)
- [ ] Player reputation (WoT)

## Year 4: Esports (2029)

- [ ] Tournament system (bracket generation)
- [ ] Prize pool management (multisig)
- [ ] Live streaming integration
- [ ] Casting tools
- [ ] Stats/analytics dashboard
- [ ] Team management
- [ ] Seasonal ranked play

## Year 5: Platform (2030)

- [ ] Map editor (community creation)
- [ ] Mod support (custom game modes)
- [ ] Workshop (share mods/maps/skins)
- [ ] Mobile port (iOS/Android)
- [ ] Console port exploration
- [ ] SDK for third-party tools

## Years 6-10: Growth (2031-2036)

- [ ] 100K+ active players
- [ ] Pro circuit with Bitcoin prize pools
- [ ] Web5 mesh network integration (peer-to-peer servers)
- [ ] AI opponents that learn from player data
- [ ] VR support
- [ ] Full open-source release
- [ ] Community governance (DAO-style, Bitcoin-native)
- [ ] The game Satoshi would play

---

*"Build it and they will come."* — Zazawowow, 2026
