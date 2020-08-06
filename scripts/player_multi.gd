extends player

var send_position_time = 0.2
var current_send_position_time = 0

var puppet_position_correction_speed = 50
var puppet_max_correction_distance = 200
var puppet_min_correction_distance = 10
var puppet_master_position_differrence = Vector2(0,0)

puppet var puppet_position = Vector2()
puppet var puppet_movement = Vector2()
puppet var puppet_hp_points = 100
puppet var puppet_animation = "stand"
puppet var puppet_move = "stand"

func _process(delta):
	if is_network_master():
		if current_send_position_time > 0:
			current_send_position_time -= delta
		else:
			rpc("set_puppet_master_position_difference", position)
			current_send_position_time = send_position_time
	pass

func player_actions(delta):
	if is_network_master():
		.player_actions(delta)
	else:
		player_puppet_actions(delta)
	pass
	
func player_puppet_actions(delta):
	if puppet_move == "left":
		if movement.x != -move_speed:
			movement.x = -move_speed
		if $animated_sprite.animation != "run":
			$animated_sprite.play("run")
		if not flipped_left:
			flip_player_left()
	elif puppet_move == "right":
		if movement.x != move_speed:
			movement.x = move_speed
		if $animated_sprite.animation != "run":
			$animated_sprite.play("run")
		if flipped_left:
			flip_player_right()
	elif puppet_move == "stand":
		if movement.x != 0:
			movement.x = 0
		$animated_sprite.play("stand")
		
	movement.y += gravity_force * delta
	
	puppet_position_correction(delta)
	
	if !is_on_floor():
		if movement.y < 0:
			$animated_sprite.play("jump_up")
		else:
			$animated_sprite.play("jump_down")
			
	hp_points = puppet_hp_points
	$hp_bar.value = hp_points
	pass

func move_left():
	.move_left()
	rpc("move_puppet_player", "left", position)
	pass

func move_right():
	.move_right()
	rpc("move_puppet_player", "right", position)
	pass

func stand():
	.stand()
	rpc("move_puppet_player", "stand", position)
	pass

func set_anim_stand():
	.set_anim_stand()
	rpc("move_puppet_player", "stand", position)
	pass

func jump():
	.jump()
	rpc("move_puppet_player", "jump", position)
	pass
	
func set_hp(hp):
	.set_hp(hp)
	rset("puppet_hp_points", hp)
	pass

puppet func move_puppet_player(action, pos):
	if action == "jump":
		movement.y = jump_force
	else:
		puppet_move = action
		
	#set_puppet_master_position_difference(pos)
	pass

puppet func set_puppet_master_position_difference(pos):
	puppet_master_position_differrence = pos - position
#	print_debug(puppet_master_position_differrence)
#	print_debug(puppet_master_position_differrence.length())
#	print_debug(Vector2(puppet_position_correction_speed, puppet_position_correction_speed) * Vector2(0,0).direction_to(puppet_master_position_differrence))
#	print_debug(Vector2(0,0).direction_to(puppet_master_position_differrence))
#	pass

func puppet_position_correction(delta):
	var length = puppet_master_position_differrence.length()
	#print_debug(length)
	if length <= puppet_max_correction_distance and length > puppet_min_correction_distance:
		var move_val = Vector2(puppet_position_correction_speed, puppet_position_correction_speed) * Vector2(0,0).direction_to(puppet_master_position_differrence) * delta
		position += move_val
		puppet_master_position_differrence -= move_val
	elif length > puppet_max_correction_distance:
		position += puppet_master_position_differrence
		puppet_master_position_differrence = Vector2(0,0)
		pass
	pass

puppet func shoot_bullet(position, direction):
	.shoot_bullet(position, direction)
	if is_network_master():
		rpc("shoot_bullet", position, direction)
	pass
	
func deal_dmg(area):
	if not area.bullet_master == get_network_master():
		hp_points -= area.bullet_dmg
		if hp_points <= 0:
			dead()
		#area.queue_free()
	pass
	
func dead():
	var spawn_point_id = game_config.rand.randi() % 4
	position = get_tree().get_root().get_node("map/spawn_points/" + str(spawn_point_id)).position
	rpc("move_puppet_player", "stand", position)
	hp_points = max_hp_points
	rset("puppet_hp_points", hp_points)
	kill()
	rpc("kill")
	pass
	
puppet func kill():
	multi_game.players_alife[get_network_master()].lifes -= 1
	get_tree().get_root().get_node("in_game_ui").delete_life(get_network_master())
	if multi_game.players_alife[get_network_master()].lifes == 0:
		if is_network_master():
			var camera = load("res://scenes/camera.tscn").instance()
			camera.zoom = Vector2(2,2)
			get_tree().get_root().get_node("map/center_point").add_child(camera)
		multi_game.players_alife.erase(get_network_master())
		if multi_game.players_alife.size() == 1:
			multi_game.pre_end_game()
		queue_free()
	pass

func hit_box_trigger(area):
	if area.is_in_group("bullet") and is_network_master():
		deal_dmg(area)
	pass # Replace with function body.
