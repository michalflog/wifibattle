extends KinematicBody2D

class_name enemy

export var hp = 100
export var dmg = 20
export var max_hp = 100
export var movement_speed = 150
export var gravity_force = 1000
export var points = 5

export var max_movement_speed = 300
export var hp_multiplier = 1.1
export var dmg_multiplier = 1.5
export var movement_multiplier = 1.01

var movement = Vector2(0,0)
var move_direction = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("enemy")
	$hit_box.add_to_group("enemy")
	$hit_box.connect("area_entered", self, "hit_box_trigger")
	pass # Replace with function body.
	
func _process(delta):
	
	if not game_config.pause:
		
		if is_on_wall():
			move_direction *= -1
			
		$animated_sprite.flip_h = (move_direction.x == -1) 
		movement.x = move_direction.x * movement_speed
		movement.y += gravity_force * delta
			
		movement = move_and_slide(movement, Vector2(0, -1), true)
	
	pass

func take_damage(dmg_val):
	hp -= dmg_val
	update_hp_bar()
	if hp <= 0:
		kill()
	pass
	
func kill():
	signals.add_points(points)
	dead()
	pass
	
func dead():
	signals.enemy_dead()
	queue_free()
	pass
	
func update_hp_bar():
	var hp_bar = find_node("hp_bar")
	hp_bar.value = hp
	hp_bar.max_value = max_hp
	pass

func hit_box_trigger(area):
	if area.is_in_group("bullet"):
		var new_bullet : bullet = area 
		take_damage(new_bullet.bullet_dmg)
	pass
	
func upgrade(wave, enemie_upgrade):
	var color_change = 0.25
	var upgrade_amount = wave + enemie_upgrade
	var color_amount : float = enemie_upgrade * color_change
	var color = Color(1 + color_amount, 1, 1)
	var sprite : AnimatedSprite = find_node("animated_sprite")
	sprite.set_modulate(color)
	
	hp = hp * pow(hp_multiplier, upgrade_amount)
	max_hp = hp
	update_hp_bar()
	
	dmg = dmg * pow(dmg_multiplier, upgrade_amount)
	movement_speed = movement_speed * pow(movement_multiplier, upgrade_amount)
	
	if movement_speed > max_movement_speed:
		movement_speed = max_movement_speed
	
	pass

