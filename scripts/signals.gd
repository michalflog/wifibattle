extends Node

signal show_accept_window(title, text, close_on)
signal accept_window_closed
signal audio_change
signal show_single_lobby
signal hide_single_lobby
signal change_pause
signal update_flower_hp(hp, max_hp)
signal end_single_game
signal add_points(points)
signal update_points(points)
signal next_wave
signal enemy_dead
signal player_dead(player_copy)
signal timeout(timeout_name)
signal timer_time(time)
signal end_timer

func emit_show_accept_window(title, text, close_on = 0):
	emit_signal("show_accept_window", title, text, close_on)
	
func emit_accept_window_closed():
	emit_signal("accept_window_closed")
	
func emit_audio_change():
	emit_signal("audio_change")
	
func show_single_lobby():
	emit_signal("show_single_lobby")
	pass
	
func hide_single_lobby():
	emit_signal("hide_single_lobby")
	pass
	
func change_pause():
	emit_signal("change_pause")
	pass
	
func update_flower_hp(hp, max_hp):
	emit_signal("update_flower_hp", hp, max_hp)
	pass
	
func end_single_game():
	emit_signal("end_single_game")
	pass
	
func add_points(points):
	emit_signal("add_points", points)
	pass

func update_points(points):
	emit_signal("update_points", points)
	pass
	
func next_wave():
	emit_signal("next_wave")
	
func enemy_dead():
	emit_signal("enemy_dead")
	
func player_dead(player_copy : player):
	emit_signal("player_dead", player_copy)
	
func timeout(timeout_name : String):
	emit_signal("timeout", timeout_name)
	
func timer_time(time : int):
	emit_signal("timer_time", time)
	
func end_timer():
	emit_signal("end_timer")
