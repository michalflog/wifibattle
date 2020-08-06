extends KinematicBody2D

class_name enemy

export var hp = 100
export var dmg = 20
export var max_hp = 100
export var movement_speed = 150
export var gravity_force = 1000
export var is_flying = false
export var points = 5

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
		if not is_flying:
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
	$hp_bar.value = hp
	pass

func hit_box_trigger(area):
	if area.is_in_group("bullet"):
		var new_bullet : bullet = area 
		take_damage(new_bullet.bullet_dmg)
	pass

