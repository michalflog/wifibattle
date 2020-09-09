extends Node

var map_scene

var points = 0
var wave = 0
var player_copy : player
var current_timer : timer

func _ready():
	map_scene = preload("res://scenes/single_tile_map.tscn")
	signals.connect("end_single_game", self, "end_single_game")
	signals.connect("add_points", self, "add_points")
	signals.connect("player_dead", self, "player_dead")
	signals.connect("end_timer", self, "end_timer")
	pass # Replace with function body.
	
func start_game():
	var map = map_scene.instance()
	map.get_node("player").set_player_stats(game_config.char_id)
	get_tree().get_root().add_child(map)
	signals.hide_single_lobby()
	pass
	
func load_game():
	pass
	
func end_single_game():
	game_config.change_game_pause()
	game_config.save_config_file(points, wave)
	signals.emit_show_accept_window("Flower has been destroyed", "Your score is " + String(points))
	yield(signals, "accept_window_closed")
	end_game()
	game_config.change_game_pause()
	pass
	
func end_game():
	points = 0
	wave = 0
	signals.show_single_lobby()
	get_tree().get_root().get_node("map").queue_free()
	pass
	
func add_points(added_points):
	points += added_points
	update_points()
	pass
	
func update_points():
	signals.update_points(points)
	pass
	
func player_dead(copy_of_player : player):
	player_copy = copy_of_player
	
	add_timer(3, "respawn")
	get_tree().get_root().get_node("map").find_node("camera")._set_current(true)
	pass
	
func respawn_player():
	get_tree().get_root().get_node("map").find_node("camera")._set_current(false)
	get_tree().get_root().get_node("map").call_deferred("add_child", player_copy)
	player_copy.immute()
	pass
	
func next_wave():
	signals.next_wave()
	wave += 1
	signals.update_waves(wave)
	pass
	
func add_timer(time : int, name : String):
	if current_timer == null:
		current_timer = timer.new(time, name)
		add_child(current_timer)
	else:
		match name:
			"respawn":
				if current_timer.timer_name == "next_wave":
					respawn_player()
			"next_wave":
				if current_timer.timer_name == "respawn":
					end_timer()
					add_timer(time, name)
	pass
	
func end_timer():
	match current_timer.timer_name:
		"respawn":
			respawn_player()
		"next_wave":
			next_wave()
	current_timer.queue_free()
	current_timer = null
	pass
	
func save_game():
	pass

