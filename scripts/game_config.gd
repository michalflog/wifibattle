extends Node

var characters = []
var char_id = 0
var rand = RandomNumberGenerator.new()
var close_accept_window_val = 0
var audio_on = true
var pause = false

func _ready():
	characters.append(character.new(2, 2, 2, "blue"))
	characters.append(character.new(1, 3, 2, "green"))
	characters.append(character.new(3, 2, 1, "red"))
	characters.append(character.new(2, 1, 3, "gray"))
	rand.randomize()
	pass
	
func _finalize():
	pass 

func _notification(what):
	if OS.get_name() == "Android":
		if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
				show_quit_window()
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		show_quit_window()
	pass
	
func show_quit_window():
	signals.emit_show_accept_window("You're about to quit", "Do you want to do it?", 1)
	yield(signals, "accept_window_closed")
	if close_accept_window_val == 1:
		if not multi_game.peer == null:
			if multi_game.peer.CONNECTION_CONNECTED:
				multi_game.close_connection()
		get_tree().quit()
	pass
	
func change_audio():
	audio_on = !audio_on
	signals.emit_audio_change()
	
func change_game_pause():
	pause = !pause
	signals.change_pause()
