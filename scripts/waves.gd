extends Node

class_name waves

func _ready():
	pass # Replace with function body.

var waves_set = {
	1 : {
		spawn_time = 2,
		enemies = [
			{
				name = "enemy_walk",
				number = 2,
				upgrade = 0
			}
		]
	},
	2 : {
		spawn_time = 1,
		enemies = [
			{
				name = "enemy_walk",
				number = 4,
				upgrade = 0
			}
		]
	}
}
