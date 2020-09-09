extends Node

signal server_created
signal connection_ok
signal connection_fail
signal update_servers_list
signal update_players_list
signal server_closed
signal close_connection
signal hide_game_lobby
signal show_multi_game_lobby
signal set_multi_start_button(val)

var udp = PacketPeerUDP.new()
var peer : NetworkedMultiplayerENet
var server_port = 2020
var broadcast_port = 2040
var max_players = 4

var is_listening = false
var is_broadcasting = false
var next_broadcast_send = 1

var server_name
var servers = {}
var player_name
var player_points = 0
var players = {}
var players_alife = {}

var maps = []
var characters = []
var player_scene
var camera_scene
var in_game_ui_scene
var player_lifes_scene

# Called when the node enters the scene tree for the first time.
func _ready():
	udp.set_broadcast_enabled(true)
	get_tree().connect("network_peer_connected", self, "network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "network_peer_disconnected")
	get_tree().connect("connected_to_server", self, "connected_to_server")
	get_tree().connect("connection_failed", self, "connection_failed")
	get_tree().connect("server_disconnected", self, "server_disconnected")
	maps.append(load("res://scenes/red_tilemap.tscn"))
	maps.append(load("res://scenes/blue_tilemap.tscn"))
	maps.append(load("res://scenes/yellow_tilemap.tscn"))
	characters.append(load("res://scenes/animated_sprite_blue.tscn"))
	characters.append(load("res://scenes/animated_sprite_green.tscn"))
	characters.append(load("res://scenes/animated_sprite_red.tscn"))
	characters.append(load("res://scenes/animated_sprite_gray.tscn"))
	player_scene = load("res://scenes/player_multi.tscn")
	camera_scene = load("res://scenes/camera.tscn")
	in_game_ui_scene = preload("res://scenes/in_game_ui.tscn")
	player_lifes_scene = load("res://scenes/player_lifes.tscn")
	pass # Replace with function body.
	
func _process(delta):
	if get_tree().has_network_peer():
		if get_tree().is_network_server() and is_broadcasting:
			if next_broadcast_send > 0:
				next_broadcast_send -= delta
			else:
				send_broadcast_packet(get_server_name(), 0)
				next_broadcast_send = 1
	elif is_listening:
		if udp.get_available_packet_count() > 0:
			read_broadcast_packet()
	pass
	
func send_broadcast_packet(txt, id):
	udp.set_dest_address("255.255.255.255", broadcast_port)
	var msg
	if id == 0:
		msg = "657201_" + txt
	elif id == 1:
		msg = "438910_" + txt
	var packet = msg.to_ascii()
	udp.put_packet(packet) 
	#print_debug(msg)
	pass
	
func read_broadcast_packet():
	var packet = udp.get_packet()
	var ip = udp.get_packet_ip()
	var stg = packet.get_string_from_ascii()
	if stg != "":
		var stg_array = stg.split("_")
		if stg_array.size() == 2:
			if stg_array[0] == "657201":
				if not ip in servers:
					servers[ip] = stg_array[1]
					emit_signal("update_servers_list")
			if stg_array[0] == "438910" and stg_array[1] == "close":
				servers.erase(ip)
				emit_signal("update_servers_list")
	#print_debug(stg)
	pass
	
func start_listening():
	udp.listen(broadcast_port, "0.0.0.0")
	is_listening = true
	pass
	
func stop_listening():
	udp.close()
	is_listening = false
	pass
		
func close_connection():
	
	if get_tree().is_network_server():
		send_broadcast_packet("close", 1)
		
	peer.close_connection()
	players.clear()
	get_tree().set_network_peer(null)
	udp.close()
		
	emit_signal("close_connection")
	pass

remote func add_player(name):
	var id = get_tree().get_rpc_sender_id()
	players[id] = {"name": name, "points": 0, "char_id": 0, "ready": false}
	emit_signal("update_players_list")
	pass
	
func network_peer_connected(id):
	rpc_id(id, "add_player", multi_game.get_player_name())
	pass

func network_peer_disconnected(id):
	if get_tree().get_root().has_node("map"):
		get_tree().get_root().get_node("map").get_node(String(id)).queue_free()
		get_tree().get_root().get_node("in_game_ui").delete_player_lifes(id)
	players.erase(id)
	players_alife.erase(id)
	emit_signal("update_players_list")
	if players_alife.size() == 1:
		signals.emit_show_accept_window("You're the last player", "The game will end now")
		yield(signals, "accept_window_closed")
		disconnect_game()
		pass
	pass
	
func connected_to_server():
	stop_listening()
	emit_signal("connection_ok")
	pass
	
func connection_failed():
	servers.clear()
	emit_signal("update_servers_list")
	start_listening()
	emit_signal("connection_fail")
	pass
	
func server_disconnected():
	print_debug("server disconnected")
	if get_tree().get_root().has_node("map"):
		free_multi_game_scenes()
		signals.emit_show_accept_window("Connection lost", "Host has disconnected")
		
	close_connection()	
	emit_signal("server_closed")
	
func free_multi_game_scenes():
	get_tree().get_root().get_node("map").queue_free()
	get_tree().get_root().get_node("in_game_ui").queue_free()
	pass
	
func host_game():
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(server_port, max_players)
	peer.compression_mode = 4
	get_tree().set_network_peer(peer)
	is_broadcasting = true
	emit_signal("server_created")
	pass
	
func join_game(address):
	stop_listening()
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(address, server_port)
	peer.compression_mode = 4
	get_tree().set_network_peer(peer)
	pass
	
remote func change_player_character(id):
	var p_id = get_tree().get_rpc_sender_id()
	players[p_id].char_id = id
	pass
	
remote func player_ready_to_start(ready):
	var id = get_tree().get_rpc_sender_id()
	print_debug(id)
	players[id].ready = ready
	check_if_can_start_game()
	pass
	
func check_if_can_start_game():
	if check_if_players_ready_to_start_game() and game_config.char_available():
		emit_signal("set_multi_start_button", false)
	else:
		emit_signal("set_multi_start_button", true)
	pass
	
func check_if_players_ready_to_start_game():
	for pl in players:
		if pl != 1 and !players[pl].ready:
			return false
	return true
	pass
	
func load_game():
	peer.refuse_new_connections = true
	send_broadcast_packet("close", 1)
	is_broadcasting = false
	
	players_ready.clear()
	
	var map_id = game_config.rand.randi() % 3

	var spawn_points = {}
	spawn_points[get_tree().get_network_unique_id()] = game_config.rand.randi() % 4
	for p in players:
		var save_spawn_point = false
		var spawn_point_id
		while !save_spawn_point:
			spawn_point_id = game_config.rand.randi() % 4
			var no_same_spawn_point = true
			for sp in spawn_points:
				if spawn_points[sp] == spawn_point_id:
					no_same_spawn_point = false
					break
			if no_same_spawn_point:
				save_spawn_point = true
		spawn_points[p] = spawn_point_id
	
	pre_start_game(map_id, spawn_points)
	rpc("pre_start_game", map_id, spawn_points)
	pass
	
remote func pre_start_game(map_id, spawn_points):
	emit_signal("hide_game_lobby")
	get_tree().set_pause(true)
	players_alife.clear()
	var map = maps[map_id].instance()
	
	for sp in spawn_points:
		var player = player_scene.instance()
		player.set_name(str(sp))
		player.set_network_master(sp)
		player.position = map.get_node("spawn_points/" + str(spawn_points[sp])).position
		if sp == get_tree().get_network_unique_id():
			player.get_node("player_name").text = player_name
			player.set_player_stats(game_config.char_id)
			var camera = camera_scene.instance()
			player.add_child(camera)
			players_alife[sp] = {"name": player_name, "lifes": 3}
		else:
			for p in players:
				if p == sp:
					player.get_node("player_name").text = players[p].name
					player.set_player_stats(players[p].char_id)
					break
			players_alife[sp] = {"name": players[sp].name, "lifes": 3}			
		map.add_child(player)
	
	get_tree().get_root().add_child(map)
	
	var in_game_ui = in_game_ui_scene.instance()
	for p in players_alife:
		var player_lifes = player_lifes_scene.instance()
		player_lifes.name = str(p)
		player_lifes.get_node("player_name").text = players_alife[p].name
		in_game_ui.get_node("players_lifes").add_child(player_lifes)
	get_tree().get_root().add_child(in_game_ui)
	
	if get_tree().is_network_server():
		if players.size() == 0:
			start_game()
		else:
			player_ready(1)
	else:
		rpc_id(1, "player_ready", get_tree().get_network_unique_id())
	
	pass

var players_ready = []
	
remote func player_ready(id):
	if not id in players_ready:
		players_ready.append(id)
	if players_ready.size() == players.size() + 1:	
		start_game()
		rpc("start_game")
		players_ready.clear()
	pass
	
remote func start_game():
	get_tree().set_pause(false)
	pass

remote func pre_end_game():
	var text
	for p in players_alife:
		if p == get_tree().get_network_unique_id():
			player_points += 1
			text = "You have won the game"
		else:
			players[p].points += 1
			text = players[p].name + "has won the game"
	
	signals.emit_show_accept_window("The game has ended", text)
	yield(signals, "accept_window_closed")
	get_tree().set_pause(true)
	end_game()
	
#	if get_tree().is_network_server():
#		player_ready_to_end_game(get_tree().get_network_unique_id())
#	else:
#		rpc_id(1, "player_ready_to_end_game", get_tree().get_network_unique_id())
	pass
	
remote func player_ready_to_end_game(id):
	if not id in players_ready:
		players_ready.append(id)
	if players_ready.size() == players.size() + 1:	
		end_game()
		rpc("end_game")
		players_ready.clear()
	pass

remote func end_game():
	peer.refuse_new_connections = false
	free_multi_game_scenes()
	get_tree().set_pause(false)
	emit_signal("show_multi_game_lobby")
	emit_signal("update_players_list")
	pass
	
func disconnect_game():
	free_multi_game_scenes()
	close_connection()
	pass

func set_server_name(name):
	server_name = name
	
func get_server_name():
	return(server_name)
	
func set_player_name(name):
	player_name = name
	
func get_player_name():
	return(player_name)
	
func clear_servers():
	servers.clear()
	emit_signal("update_servers_list")
