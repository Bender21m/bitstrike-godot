# ₿ITSTRIKE — 5 YEAR PLAN

**Vision:** The definitive Bitcoin FPS. Counter-Strike gameplay, Bitcoin economy, open source.

---

## PHASE 1: FOUNDATION (Now → Q3 2026)
*Goal: Playable single-player that feels like CS 1.6*

### Immediate (Next 2 weeks)
- [ ] Fix weapon viewmodel with proper .tscn scene wrapper for GLB arms
- [ ] Import real weapon models (AK, M4, pistol, sniper) from Sketchfab
- [ ] Import Mixamo character models for enemies (replace capsule-people)
- [ ] Real .ogg sound effects (gunshots, footsteps, ambient)
- [ ] Wall/floor textures on all maps
- [ ] Fix all gameplay bugs (popups, spawning, hit registration)

### Short-term (Q2 2026)
- [x] FPS controller with CS movement (done)
- [x] 6 maps (done)
- [x] Buy menu, economy (done)
- [x] Enemy AI: patrol, chase, flank, cover (done)
- [x] Hack/defuse game mode (done)
- [x] Kill streaks, death/respawn (done)
- [x] CI/CD with Godot editor import pipeline (done)
- [ ] Proper weapon viewmodels with arms + animations
- [ ] Settings that persist (localStorage)
- [ ] Sensitivity/FOV/crosshair customization working
- [ ] All 6 enemy types visually distinct with real models
- [ ] Skyboxes per map

### Mid-term (Q3 2026)
- [ ] Matchmaking lobby UI
- [ ] Bot difficulty levels (Easy/Normal/Hard/Expert)
- [ ] Competitive mode (MR15, overtime, full economy)
- [ ] 12 maps total
- [ ] Weapon skins system (visual customization)
- [ ] Kill cam / death replay
- [ ] Sound occlusion (muffled through walls)
- [ ] Footstep sounds per surface (metal, wood, concrete)
- [ ] Grenade physics polish (bounce, roll)
- [ ] Armor visual on player/enemies

---

## PHASE 2: MULTIPLAYER (Q4 2026 → Q2 2027)
*Goal: Play with friends online*

### Q4 2026
- [ ] WebSocket server (Node.js or Rust)
- [ ] Client-server architecture
- [ ] Basic lobby system (create/join room)
- [ ] Player sync (position, rotation, shooting)
- [ ] 2v2 prototype matches

### Q1 2027
- [ ] 5v5 competitive (Bitcoiners vs Shitcoiners)
- [ ] Server-side hit validation (anti-cheat basics)
- [ ] Lag compensation / client prediction
- [ ] Voice chat (WebRTC)
- [ ] Server browser

### Q2 2027
- [ ] Matchmaking with skill-based ranking
- [ ] ELO system + leaderboards
- [ ] Player profiles (stats, match history)
- [ ] Spectator mode
- [ ] Replay system

---

## PHASE 3: BITCOIN INTEGRATION (Q3 2027 → Q2 2028)
*Goal: Real sats on the line*

### Q3 2027
- [ ] Lightning wallet integration (LNbits / NWC)
- [ ] Sats wagering on matches (optional)
- [ ] Winner-takes-pot tournaments
- [ ] Nostr login (npub identity)

### Q4 2027
- [ ] Weapon/character skins purchasable with real sats
- [ ] P2P skin marketplace
- [ ] Bounty system (put sats on a player's head mid-match)
- [ ] Game events posted to Nostr relays

### Q1-Q2 2028
- [ ] Tournament brackets with multisig prize pools
- [ ] Streaming integration (zap to support players)
- [ ] Season passes (sats-funded prize pools)
- [ ] Community map voting

---

## PHASE 4: ESPORTS (Q3 2028 → Q4 2029)
*Goal: Competitive scene with real stakes*

- [ ] Ranked seasons with rewards
- [ ] Pro tournament system (brackets, seeding)
- [ ] Casting/commentary tools
- [ ] Live streaming with overlay stats
- [ ] Team creation + management
- [ ] Anti-cheat v2 (server-side demo recording)
- [ ] Custom game modes (gun game, deathmatch, retake)
- [ ] Map editor (community-created maps)

---

## PHASE 5: PLATFORM (2030-2031)
*Goal: Self-sustaining game ecosystem*

- [ ] Mobile port (iOS/Android)
- [ ] Console exploration (Steam Deck first)
- [ ] Mod support + workshop
- [ ] SDK for third-party tools
- [ ] Community governance (Bitcoin-native voting)
- [ ] Open-source everything
- [ ] 100K+ monthly active players
- [ ] VR support exploration
- [ ] AI opponents that learn from player data

---

## CURRENT STATUS

**What works today (v0.3):**
- 6 maps, 5 weapons + knife, full buy menu
- CS-style recoil, crouching, jumping affects accuracy
- Hack/defuse game mode (Bitcoiners vs Shitcoiners)
- Enemy AI with LOS checks, patrol, chase, flank, cover
- Kill streaks, death screen, respawn
- Minimap, scoreboard, settings menu
- Grenade system (flashbang, BCash explosive, smoke)
- CI/CD with Godot editor import pipeline
- 34 scripts, 10K+ lines

**What needs fixing RIGHT NOW:**
1. Weapon viewmodel (clean procedural, arms need scene wrapper)
2. Real 3D models (weapons, characters, props)
3. Real sound effects (replace procedural synthesis)
4. Map textures and skyboxes
5. Polish, polish, polish

---

*"When in doubt, do what CS 1.6 would do."* — Zazawowow, 2026
