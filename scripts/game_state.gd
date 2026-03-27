extends Node

var round = 1
var game_over = false
var buy_phase = false
var buy_timer = 0.0
var round_wins = 0

var weapons = [
	{"name":"AK-B7","ammo":30,"max_ammo":30,"reserve":90,"damage":25,"fire_rate":0.1,"auto":true,"recoil":0.06,"price":2700},
	{"name":"BEAGLE","ammo":7,"max_ammo":7,"reserve":35,"damage":55,"fire_rate":0.4,"auto":false,"recoil":0.1,"price":700},
	{"name":"SABOT","ammo":5,"max_ammo":5,"reserve":20,"damage":120,"fire_rate":0.8,"auto":false,"recoil":0.15,"price":4750}
]

func next_round():
	round += 1; round_wins += 1; buy_phase = true; buy_timer = 10.0
