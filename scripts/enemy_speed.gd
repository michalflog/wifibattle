extends enemy

class_name enemy_speed

# Called when the node enters the scene tree for the first time.
func _ready():
	$animated_sprite.play("run")
	pass # Replace with function body.

func _process(delta):
	if find_node("RayCast2D").get_collider():
		if find_node("RayCast2D").get_collider().is_in_group("map"):
			movement.y -= gravity_force * delta * 1.25
	else:
		movement.y -= gravity_force * delta * 0.75
		
#	if is_on_wall():
#		$animated_sprite.flip_h = !$animated_sprite.flip_h
	pass
