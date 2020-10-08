extends Node

class_name waves

func _ready():
	pass # Replace with function body.

var waves_set = {
	1 : {
		spawn_time = 1,
		enemies = [
			{
				name = "enemy_walk",
				number = 1,
				upgrade = 0
			},
			{
				name = "enemy_speed",
				number = 1,
				upgrade = 0
			},
			{
				name = "enemy_fly",
				number = 1,
				upgrade = 0
			},
		]
	},
	2 : {
		spawn_time = 1,
		enemies = [
			{
				name = "enemy_walk",
				number = 6,
				upgrade = 0
			}
		]
	},
	3 : {
		spawn_time = 1,
		enemies = [
			{
				name = "enemy_speed",
				number = 6,
				upgrade = 0
			}
		]
	},
	4 : {
		spawn_time = 1,
		enemies = [
			{
				name = "enemy_fly",
				number = 6,
				upgrade = 0
			}
		]
	},
	5 : {
		spawn_time = 1,
		enemies = [
			{
				name = "enemy_walk",
				number = 4,
				upgrade = 0
			},
			{
				name = "enemy_speed",
				number = 4,
				upgrade = 0
			},
			{
				name = "enemy_fly",
				number = 4,
				upgrade = 0
			},
		]
	},
	6 : {
		spawn_time = 0.8,
		enemies = [
			{
				name = "enemy_walk",
				number = 8,
				upgrade = 1
			},
			{
				name = "enemy_speed",
				number = 4,
				upgrade = 1
			},
		]
	},
	7 : {
		spawn_time = 0.8,
		enemies = [
			{
				name = "enemy_walk",
				number = 8,
				upgrade = 1
			},
			{
				name = "enemy_fly",
				number = 4,
				upgrade = 1
			},
		]
	},
	8 : {
		spawn_time = 0.8,
		enemies = [
			{
				name = "enemy_speed",
				number = 8,
				upgrade = 1
			},
			{
				name = "enemy_walk",
				number = 4,
				upgrade = 1
			},
		]
	},
	9 : {
		spawn_time = 0.8,
		enemies = [
			{
				name = "enemy_fly",
				number = 8,
				upgrade = 1
			},
			{
				name = "enemy_walk",
				number = 4,
				upgrade = 1
			},
		]
	},
	10 : {
		spawn_time = 0.8,
		enemies = [
			{
				name = "enemy_walk",
				number = 5,
				upgrade = 1
			},
			{
				name = "enemy_speed",
				number = 5,
				upgrade = 1
			},
			{
				name = "enemy_fly",
				number = 5,
				upgrade = 1
			},
		]
	},
}
