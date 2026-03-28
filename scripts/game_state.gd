extends Node

var round = 1
var game_over = false
var buy_phase = false
var buy_timer = 0.0
var round_wins = 0

const BUY_PHASE_DURATION = 15.0  # seconds between rounds

var weapons = [
	{"name":"AK-B7","ammo":30,"max_ammo":30,"reserve":90,"damage":25,"fire_rate":0.1,"auto":true,"recoil":0.06,"price":2700},
	{"name":"BEAGLE","ammo":7,"max_ammo":7,"reserve":35,"damage":55,"fire_rate":0.4,"auto":false,"recoil":0.1,"price":700},
	{"name":"SABOT","ammo":5,"max_ammo":5,"reserve":20,"damage":120,"fire_rate":0.8,"auto":false,"recoil":0.15,"price":4750}
]

func next_round():
	round += 1
	round_wins += 1
	start_buy_phase()

func start_buy_phase():
	buy_phase = true
	buy_timer = BUY_PHASE_DURATION
	# Auto-open buy menu
	var buy_menu = get_tree().root.find_child("BuyMenu", true, false)
	if buy_menu and buy_menu.has_method("open_menu"):
		buy_menu.open_menu()

func end_buy_phase():
	buy_phase = false
	buy_timer = 0.0
	# Force-close buy menu
	var buy_menu = get_tree().root.find_child("BuyMenu", true, false)
	if buy_menu and buy_menu.has_method("close_menu"):
		buy_menu.close_menu()

func _process(delta):
	if buy_phase:
		buy_timer -= delta
		if buy_timer <= 0:
			end_buy_phase()
