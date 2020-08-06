class_name character

var health : int
var speed : int
var damage : int
var sprite_scene

func _init(hp, spd, dmg, sprite):
	health = hp
	speed = spd
	damage = dmg
	sprite_scene = load("res://scenes/animated_sprite_" + sprite + ".tscn")
	
func get_health_value():
	var hp_val
	match health:
		1: hp_val = 75
		2: hp_val = 100
		3: hp_val = 120
	return hp_val
	
func get_speed_value():
	var spd_val
	match speed:
		1: spd_val = 180
		2: spd_val = 200
		3: spd_val = 250
	return spd_val
	
func get_damage_value():
	var dmg_val
	match damage:
		1: dmg_val = 20
		2: dmg_val = 25
		3: dmg_val = 38
	return dmg_val
	pass
