extends KinematicBody2D

class_name player

export (PackedScene) var bullet_scene

var reload_time = 0.25
var current_reload_time = 0
var move_speed = 200
var jump_force = -500
var gravity_force = 1000
var movement = Vector2()
var max_hp_points = 100
var hp_points = 100
var current_move_state = "stand"
var damage = 25

var immute_time = 3
var current_immute_time = 0
var is_immute = false

var double_jump = false
var flipped_left = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$hit_box.connect("area_entered", self, "hit_box_trigger")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if not game_config.pause:
		player_actions(delta)
		
		if current_immute_time > 0:
			current_immute_time -= delta
		else:
			is_immute = false
			
		movement = move_and_slide(movement, Vector2(0, -1), true)
			
		if movement == Vector2(0, 0):
			$particles.emitting = false
		else:
			$particles.emitting = true
			$particles.direction = movement
	
	pass

func player_actions(delta):
	if Input.is_action_pressed("left"):
		if movement.x != -move_speed:
			move_left()
		if $animated_sprite.animation != "run":
			$animated_sprite.play("run")
		if not flipped_left:
			flip_player_left()		
	elif Input.is_action_pressed("right"):
		if movement.x != move_speed:
			move_right()
		if $animated_sprite.animation != "run":
			$animated_sprite.play("run")
		if flipped_left:
			flip_player_right()	
	else:
		if movement.x != 0:
			stand()
		if not current_move_state == "stand":
			set_anim_stand()
		$animated_sprite.play("stand")
		
	if is_on_floor():
		double_jump = true
		if Input.is_action_just_pressed("jump"):
			jump()
	else:
		if Input.is_action_just_pressed("jump") and double_jump:
			jump()
			double_jump = false
	
	movement.y += gravity_force * delta
	
	if !is_on_floor():
		if movement.y < 0:
			$animated_sprite.play("jump_up")
		else:
			$animated_sprite.play("jump_down")
	
	if Input.is_action_just_pressed("shoot") and current_reload_time <= 0:
		var bullet_position = $shoot_position.get_global_position()
		var bullet_direction
		if flipped_left:
			bullet_direction = -1
		else:
			bullet_direction = 1
			
		current_reload_time = reload_time
			
		shoot_bullet(bullet_position, bullet_direction)
		
	if current_reload_time > 0:
		current_reload_time -= delta
	
	if $hp_bar.value != hp_points:
		set_hp(hp_points)
	pass

func move_left():
	movement.x = -move_speed
	current_move_state = "left"
	pass
	
func move_right():
	movement.x = move_speed
	current_move_state = "right"
	pass
	
func stand():
	movement.x = 0
	current_move_state = "stand"
	pass
	
func set_anim_stand():
	current_move_state = "stand"
	pass
	
func jump():
	movement.y = jump_force
	pass
	
func set_hp(hp):
	$hp_bar.value = hp
	pass
	
puppet func shoot_bullet(position, direction):
	var bullet = bullet_scene.instance()
	bullet.position = position
	bullet.bullet_direction = Vector2(direction, 0)
	bullet.bullet_dmg = damage
	bullet.bullet_master = get_network_master()
	bullet.set_network_master(get_network_master())
	get_tree().get_root().add_child(bullet)
	pass
	
func deal_dmg(dmg):
	if !is_immute:
		hp_points -= dmg
		set_hp(hp_points)
		if hp_points <= 0:
			dead()
	#single player deal_dmg
	pass
	
func dead():
	signals.player_dead(self.duplicate())
	queue_free()
	#single player dead
	pass
	
puppet func kill():
	#single player kill
	pass
	
func flip_player_left():
	flipped_left = true
	$animated_sprite.flip_h = true
	$shoot_position.position.x = -20
	pass
	
func flip_player_right():
	flipped_left = false
	$animated_sprite.flip_h = false
	$shoot_position.position.x = 20
	pass	

func hit_box_trigger(area):
	if area.is_in_group("enemy"):
		deal_dmg(area.get_parent().dmg)
	elif area.is_in_group("enemy_bullet"):
		deal_dmg(area.bullet_dmg)
	#single player hit box trigger
	pass
	
func set_player_stats(char_id):
	var char_stats : character = game_config.characters[char_id]
	$animated_sprite.replace_by(char_stats.sprite_scene.instance())
	$hp_bar.max_value = char_stats.get_health_value()
	max_hp_points = char_stats.get_health_value()
	hp_points = char_stats.get_health_value()
	move_speed = char_stats.get_speed_value()
	damage = char_stats.get_damage_value()
	pass
	
func immute():
	current_immute_time = immute_time
	is_immute = true
	$immute_animation.play("immute")
	pass
