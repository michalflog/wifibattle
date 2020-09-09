extends CanvasLayer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export (Texture) var blue_player
export (Texture) var green_player
export (Texture) var red_player
export (Texture) var gray_player
export (Texture) var audio_on
export (Texture) var audio_off

var characters = []

var multi_is_ready = false

# Called when the node enters the scene tree for the first time.
func _ready():
	multi_game.connect("server_created", self, "server_created")
	multi_game.connect("connection_ok", self, "connection_ok")
	multi_game.connect("connection_fail", self, "connection_fail")
	multi_game.connect("update_servers_list", self, "update_servers_list")
	multi_game.connect("update_players_list", self, "update_players_list")
	multi_game.connect("server_closed", self, "server_closed")
	multi_game.connect("close_connection", self, "close_connection")
	multi_game.connect("hide_game_lobby", self, "hide_game_lobby")
	multi_game.connect("show_multi_game_lobby", self, "show_multi_game_lobby")
	signals.connect("show_accept_window", self, "show_accept_dialog")
	signals.connect("show_single_lobby", self, "show_single_lobby")
	signals.connect("hide_single_lobby", self, "hide_single_lobby")
	multi_game.connect("set_multi_start_button", self, "set_multi_start_button")
	characters.append(blue_player)
	characters.append(green_player)
	characters.append(red_player)
	characters.append(gray_player)
	pass # Replace with function body.

func server_created():
	$multi_lobby.hide()
	show_multi_game_lobby()
	update_players_list()
	pass

func connection_ok():
	multi_game.clear_servers()
	$servers_lobby.hide()
	show_multi_game_lobby()
	pass

func connection_fail():
	show_accept_dialog("Connection error!", "Can not connect to server")
	pass
	
func update_servers_list():
	$servers_lobby.find_node("servers_list").clear()
	var servers = multi_game.servers
	for srv in servers:
		$servers_lobby.find_node("servers_list").add_item(servers[srv])# + " (" + srv + ")")
	pass

func update_players_list():
	$multi_game_lobby.find_node("players_list").clear()
	$multi_game_lobby.find_node("players_list").add_item(multi_game.get_player_name() + " (You) " + "[" + str(multi_game.player_points) + "]")
	var players = multi_game.players
	for p in players:
		$multi_game_lobby.find_node("players_list").add_item(players[p].name + " [" + str(players[p].points) + "]")
	if get_tree().is_network_server():
		$multi_game_lobby.find_node("game_ready_button").visible = false
		multi_game.check_if_can_start_game()
	else:
		$multi_game_lobby.find_node("game_start_button").visible = false 
		$multi_game_lobby.find_node("game_ready_button").visible = true
		
	#$multi_game_lobby.find_node("game_start_button").disabled = false
	pass

func server_closed():
	pass

func close_connection():
	$multi_game_lobby.hide()
	$multi_lobby.show()
	update_multi_lobby()

func show_accept_dialog(title, text, cancel_on = 0):
	$accept_window.find_node("warning").text = title
	$accept_window.find_node("text").text = text
	if cancel_on == 1:
		$accept_window.find_node("cancel_button").show()
	$accept_window.show()
	pass

func update_multi_lobby():
	multi_game.player_points = 0
	$multi_lobby.find_node("name_line").text = multi_game.get_player_name()
	if multi_game.get_server_name() != null:
		$multi_lobby.find_node("server_line").text = multi_game.get_server_name()
	pass
	
func hide_game_lobby():
	$multi_game_lobby.hide()
	pass
	
func show_multi_game_lobby():
	game_config.char_id = 0
	change_multi_character(0)
	$multi_game_lobby.show()
	pass
	
func show_single_lobby():
	game_config.char_id = 0
	change_single_character(0)
	$single_lobby.find_node("highscore").text = String(game_config.config_data.highscore)
	$single_lobby.show()
	pass

func change_multi_character(val):
	if !multi_is_ready:
		game_config.char_id += val
		if game_config.char_id < 0:
			game_config.char_id = 3
		if game_config.char_id > 3:
			game_config.char_id = 0
		$multi_game_lobby.find_node("character").texture = characters[game_config.char_id]
		check_if_multi_character_available(game_config.char_id)
		set_multi_character_properties()
		multi_game.rpc("change_player_character", game_config.char_id)
		multi_game.check_if_can_start_game()
	pass
	
func change_single_character(val):
	game_config.char_id += val
	if game_config.char_id < 0:
		game_config.char_id = 3
	if game_config.char_id > 3:
		game_config.char_id = 0
	$single_lobby.find_node("character").texture = characters[game_config.char_id]
	check_if_single_character_available(game_config.char_id)
	set_single_character_properties()
	pass
	
func check_if_single_character_available(char_id):
	if char_id * 25 <= game_config.config_data.best_wave or game_config.config_data.unlocked_all:
		#print_debug("available")
		$single_lobby.find_node("start_game_button").disabled = false
		$single_lobby.find_node("character").self_modulate = Color(1, 1, 1)
		$single_lobby.find_node("unavailable_text").text = ""
	else:
		#print_debug("not_available")
		$single_lobby.find_node("start_game_button").disabled = true
		$single_lobby.find_node("character").self_modulate = Color(0.25, 0.25, 0.25)
		$single_lobby.find_node("unavailable_text").text = "To unlock reach %s wave" % (char_id * 25)
	pass
	
func check_if_multi_character_available(char_id):
	if char_id * 25 <= game_config.config_data.best_wave or game_config.config_data.unlocked_all:
		$multi_game_lobby.find_node("game_ready_button").disabled = false
		$multi_game_lobby.find_node("character").self_modulate = Color(1, 1, 1)
		$multi_game_lobby.find_node("unavailable_text").text = ""
	else:
		$multi_game_lobby.find_node("game_ready_button").disabled = true
		$multi_game_lobby.find_node("character").self_modulate = Color(0.25, 0.25, 0.25)
		$multi_game_lobby.find_node("unavailable_text").text = "To unlock reach %s wave in single" % (char_id * 25)
	
	pass
	
func set_multi_start_button(value):
	$multi_game_lobby.find_node("game_start_button").disabled = value
	pass

func set_multi_character_properties():
	$multi_game_lobby.find_node("properties").set_properties(game_config.char_id)
	pass

func set_single_character_properties():
	$single_lobby.find_node("properties").set_properties(game_config.char_id)
	pass

func _on_multi_button_pressed():
	$main_lobby.hide()
	$multi_lobby.show()
	pass # Replace with function body.

func _on_host_button_pressed():
	if $multi_lobby.find_node("name_line").text != "" and $multi_lobby.find_node("server_line").text != "":
		multi_game.set_player_name($multi_lobby.find_node("name_line").text)
		multi_game.set_server_name($multi_lobby.find_node("server_line").text)
		multi_game.host_game()
	elif $multi_lobby.find_node("name_line").text == "":
		show_accept_dialog("No player name!", "Set player name")
	elif $multi_lobby.find_node("server_line").text ==  "":
		show_accept_dialog("No server name!", "Set server name")
	pass # Replace with function body.

func _on_join_button_pressed():
	if $multi_lobby.find_node("name_line").text != "":
		multi_game.set_player_name($multi_lobby.find_node("name_line").text)
		$multi_lobby.hide()
		$servers_lobby.show()
		multi_game.start_listening()
	else:
		show_accept_dialog("No player name!", "Set player name")
	pass # Replace with function body.

func _on_game_back_button_pressed():
	multi_game.close_connection()
	pass # Replace with function body.
	
func _on_servers_back_button_pressed():
	multi_game.stop_listening()
	multi_game.clear_servers()
	$servers_lobby.hide()
	$multi_lobby.show()
	update_multi_lobby()
	pass # Replace with function body.
	
func _on_multi_back_button_pressed():
	$multi_lobby.hide()
	$main_lobby.show()
	pass # Replace with function body.

func _on_servers_list_item_selected(index):
	$servers_lobby.find_node("servers_join_button").disabled = false
	pass # Replace with function body.

func _on_servers_list_nothing_selected():
	$servers_lobby.find_node("servers_join_button").disabled = true
	pass # Replace with function body.

func _on_servers_join_button_pressed():
	var id = $servers_lobby.find_node("servers_list").get_selected_items()
	var servers = multi_game.servers
	var srv_id = 0
	for srv_ip in servers:
		if id[0] == srv_id:
			multi_game.join_game(srv_ip)
		srv_id += 1
	multi_game.stop_listening()
	pass # Replace with function body.

func _on_game_start_button_pressed():
	multi_game.load_game()
	pass # Replace with function body.

func _on_choose_left_pressed():
	change_multi_character(-1)
	pass # Replace with function body.

func _on_choose_right_pressed():
	change_multi_character(1)
	pass # Replace with function body.

func _on_single_button_pressed():
	$main_lobby.hide()
	show_single_lobby()
	pass # Replace with function body.

func _on_accept_button_pressed():
	game_config.close_accept_window_val = 1
	close_accept_window()
	pass # Replace with function body.
	
func _on_cancel_button_pressed():
	game_config.close_accept_window_val = 0
	close_accept_window()
	pass # Replace with function body.
	
func close_accept_window():
	$accept_window.hide()
	$accept_window.find_node("cancel_button").hide()
	signals.emit_accept_window_closed()
	pass

func _on_menu_button_pressed():
	$menu.visible = !$menu.visible
	var button = $menu.find_node("end_game_button")
	if get_tree().get_root().has_node("map"):
		button.show()
	else:
		button.hide()
	pass # Replace with function body.

func _on_sound_button_pressed():
	game_config.change_audio()
	var rect = $menu/rect.find_node("sound_button_texture")
	if game_config.audio_on:
		rect.texture = audio_on
	else:
		rect.texture = audio_off
	pass # Replace with function body.

func _on_exit_game_button_pressed():
	game_config.show_quit_window()
	pass # Replace with function body.

func _on_end_game_button_pressed():
	show_accept_dialog("You're about to end the game", "Do you want to do it?", 1)
	yield(signals, "accept_window_closed")
	if game_config.close_accept_window_val == 1:
		if multi_game.peer != null:
			if multi_game.peer.CONNECTION_CONNECTED:
				multi_game.disconnect_game()
			else:
				single_game.end_game()
		else:
			single_game.end_game()
			pass
		$menu.hide()
	pass # Replace with function body.

func _on_single_choose_left_pressed():
	change_single_character(-1)
	pass # Replace with function body.

func _on_single_choose_right_pressed():
	change_single_character(1)
	pass # Replace with function body.
	
func show_main_lobby():
	$main_lobby.show()
	pass

func hide_single_lobby():
	$single_lobby.hide()
	pass

func _on_start_game_button_pressed():
	single_game.start_game()
	pass # Replace with function body.

func _on_single_back_button_pressed():
	show_main_lobby()
	hide_single_lobby()
	pass # Replace with function body.

func _on_game_ready_button_pressed():
	if multi_is_ready:
		$multi_game_lobby.find_node("game_ready_button").modulate = Color(1,1,1)
		multi_is_ready = false
	else:
		$multi_game_lobby.find_node("game_ready_button").modulate = Color(1,2,1)
		multi_is_ready = true
	
	multi_game.rpc_id(1, "player_ready_to_start", multi_is_ready)
		
	pass # Replace with function body.
