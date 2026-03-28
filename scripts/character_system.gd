extends Node

# Character System — manages player/enemy character definitions
# Supports both procedural (current) and GLB model characters
# Drop .glb files in res://assets/models/characters/ to use real models

# Character definitions with stats, visuals, and lore
var characters: Dictionary = {
	# === ENEMY TYPES (wave enemies) ===
	"banker": {
		"display_name": "Banker",
		"faction": "fiat",
		"hp": 60, "speed": 3.0, "damage": 12,
		"reward": 5000, "accuracy": 0.5,
		"can_shoot": true, "burst": 3,
		"detection": 16.0, "attack_range": 10.0,
		"color": Color(0.4, 0.4, 0.5),
		"model_path": "res://assets/models/characters/banker.glb",
		"description": "Grey suit, red tie. Just following orders.",
	},
	"shitcoiner": {
		"display_name": "Shitcoiner",
		"faction": "fiat",
		"hp": 40, "speed": 4.5, "damage": 8,
		"reward": 3000, "accuracy": 0.35,
		"can_shoot": true, "burst": 5,
		"detection": 14.0, "attack_range": 8.0,
		"color": Color(0.6, 0.2, 0.8),
		"model_path": "res://assets/models/characters/shitcoiner.glb",
		"description": "Purple glow. Spray and pray. Probably holds SOL.",
	},
	"bear": {
		"display_name": "Bear",
		"faction": "fiat",
		"hp": 70, "speed": 3.5, "damage": 15,
		"reward": 4000, "accuracy": 0.0,
		"can_shoot": false, "burst": 0,
		"detection": 12.0, "attack_range": 1.8,
		"color": Color(0.7, 0.3, 0.3),
		"model_path": "res://assets/models/characters/bear.glb",
		"description": "Melee only. Charges you down. Thinks BTC is going to zero.",
	},
	"roger": {
		"display_name": "Roger",
		"faction": "fiat",
		"hp": 45, "speed": 5.0, "damage": 8,
		"reward": 6000, "accuracy": 0.4,
		"can_shoot": true, "burst": 2,
		"detection": 20.0, "attack_range": 12.0,
		"color": Color(0.0, 0.5, 0.0),
		"model_path": "res://assets/models/characters/roger.glb",
		"description": "Fast, erratic. Sometimes just runs away. BCash maximalist.",
	},
	"whale": {
		"display_name": "Whale",
		"faction": "fiat",
		"hp": 150, "speed": 2.0, "damage": 20,
		"reward": 8000, "accuracy": 0.6,
		"can_shoot": true, "burst": 4,
		"detection": 22.0, "attack_range": 14.0,
		"color": Color(0.27, 0.53, 0.8),
		"model_path": "res://assets/models/characters/whale.glb",
		"description": "Big. Slow. Dumps on you. Literally and figuratively.",
	},
	"fed": {
		"display_name": "Fed Chairman",
		"faction": "fiat",
		"hp": 250, "speed": 2.0, "damage": 30,
		"reward": 21000, "accuracy": 0.7,
		"can_shoot": true, "burst": 6,
		"detection": 24.0, "attack_range": 16.0,
		"color": Color(0.12, 0.12, 0.2),
		"model_path": "res://assets/models/characters/fed.glb",
		"description": "BOSS. Hat + sunglasses. Money printer goes BRRR.",
	},
	
	# === SPECIAL / BOSS CHARACTERS ===
	"satoshi": {
		"display_name": "Satoshi Nakamoto",
		"faction": "bitcoin",
		"hp": 1000, "speed": 6.0, "damage": 50,
		"reward": 210000, "accuracy": 0.9,
		"can_shoot": true, "burst": 1,
		"detection": 50.0, "attack_range": 30.0,
		"color": Color(0.97, 0.58, 0.1),
		"model_path": "res://assets/models/characters/satoshi.glb",
		"description": "Cloaked. Appears randomly. Nobody knows who he is.",
		"special_abilities": ["cloak", "teleport", "one_shot"],
		"spawn_chance": 0.03,  # 3% chance per round after R5
		"min_round": 5,
	},
	
	# === BITCOIN LEGENDS (unlockable player skins / allies) ===
	"adam_back": {
		"display_name": "Adam Back",
		"faction": "bitcoin",
		"role": "legend",
		"color": Color(0.9, 0.85, 0.7),
		"model_path": "res://assets/models/characters/adam_back.glb",
		"description": "Hashcash inventor. OG cypherpunk.",
		"perk": "headshot_bonus",  # 1.5x headshot damage
		"unlock_cost": 50000,
	},
	"nick_szabo": {
		"display_name": "Nick Szabo",
		"faction": "bitcoin",
		"role": "legend",
		"color": Color(0.6, 0.7, 0.8),
		"model_path": "res://assets/models/characters/nick_szabo.glb",
		"description": "Bit Gold. Smart contracts before Ethereum was a thought.",
		"perk": "armor_bonus",  # Start with 25 armor
		"unlock_cost": 50000,
	},
	"jameson_lopp": {
		"display_name": "Jameson Lopp",
		"faction": "bitcoin",
		"role": "legend",
		"color": Color(0.5, 0.6, 0.5),
		"model_path": "res://assets/models/characters/jameson_lopp.glb",
		"description": "Casa co-founder. Privacy maximalist. Good luck finding him.",
		"perk": "stealth",  # Enemies detect 30% slower
		"unlock_cost": 75000,
	},
	"peter_todd": {
		"display_name": "Peter Todd",
		"faction": "bitcoin",
		"role": "legend",
		"color": Color(0.4, 0.4, 0.5),
		"model_path": "res://assets/models/characters/peter_todd.glb",
		"description": "Core dev. Timelock specialist.",
		"perk": "slow_enemies",  # Enemies 15% slower
		"unlock_cost": 60000,
	},
}

# Animation mappings — what animations to look for in GLB files
var animation_names: Dictionary = {
	"idle": ["Idle", "idle", "IDLE"],
	"walk": ["Walk", "walk", "Walking", "WALK"],
	"run": ["Run", "run", "Running", "RUN", "Sprint"],
	"shoot": ["Shoot", "shoot", "Fire", "fire", "Attack", "attack"],
	"reload": ["Reload", "reload"],
	"death": ["Death", "death", "Die", "die", "Dead"],
	"hit": ["Hit", "hit", "Flinch", "flinch", "GetHit"],
	"melee": ["Melee", "melee", "Punch", "punch"],
}

# Track unlocked characters
var unlocked_legends: Array = []
var active_player_skin: String = ""

func _ready():
	# Create model directories
	if not DirAccess.dir_exists_absolute("res://assets/models/characters"):
		print("[CharacterSystem] No model directory found — using procedural characters")
		print("[CharacterSystem] To use GLB models, add them to res://assets/models/characters/")

func get_character(char_id: String) -> Dictionary:
	if characters.has(char_id):
		return characters[char_id]
	return characters["banker"]  # fallback

func get_enemy_data(char_id: String) -> Dictionary:
	var c = get_character(char_id)
	return {
		"color": c.get("color", Color(0.5, 0.5, 0.5)),
		"hp": c.get("hp", 60),
		"speed": c.get("speed", 3.0),
		"damage": c.get("damage", 12),
		"reward": c.get("reward", 5000),
		"accuracy": c.get("accuracy", 0.5),
		"can_shoot": c.get("can_shoot", true),
		"burst": c.get("burst", 3),
		"detection": c.get("detection", 16.0),
		"attack_range": c.get("attack_range", 12.0),
	}

func has_model(char_id: String) -> bool:
	var c = get_character(char_id)
	var path = c.get("model_path", "")
	return path != "" and ResourceLoader.exists(path)

func load_model(char_id: String) -> Node3D:
	var c = get_character(char_id)
	var path = c.get("model_path", "")
	if path == "" or not ResourceLoader.exists(path):
		return null
	
	var scene = load(path)
	if scene and scene is PackedScene:
		var instance = scene.instantiate()
		return instance
	return null

func find_animation(anim_player: AnimationPlayer, anim_type: String) -> String:
	if not anim_player:
		return ""
	var names = animation_names.get(anim_type, [])
	for anim_name in names:
		if anim_player.has_animation(anim_name):
			return anim_name
	# Try partial match
	for anim in anim_player.get_animation_list():
		for name_check in names:
			if anim.to_lower().contains(name_check.to_lower()):
				return anim
	return ""

func get_special_enemies_for_round(round_num: int) -> Array:
	var specials = []
	for char_id in characters:
		var c = characters[char_id]
		if not c.has("spawn_chance"):
			continue
		if round_num >= c.get("min_round", 999):
			if randf() < c.spawn_chance:
				specials.append(char_id)
	return specials

func unlock_legend(char_id: String, player_sats: int) -> Dictionary:
	if not characters.has(char_id):
		return {"success": false, "reason": "Unknown character"}
	var c = characters[char_id]
	if c.get("role", "") != "legend":
		return {"success": false, "reason": "Not a legend character"}
	if char_id in unlocked_legends:
		return {"success": false, "reason": "Already unlocked"}
	var cost = c.get("unlock_cost", 999999)
	if player_sats < cost:
		return {"success": false, "reason": "Not enough sats (need %d)" % cost}
	unlocked_legends.append(char_id)
	return {"success": true, "cost": cost}

func get_perk(char_id: String) -> String:
	var c = get_character(char_id)
	return c.get("perk", "")

func get_legends() -> Array:
	var legends = []
	for char_id in characters:
		if characters[char_id].get("role", "") == "legend":
			legends.append(char_id)
	return legends
