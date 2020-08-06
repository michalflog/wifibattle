extends enemy

# Called when the node enters the scene tree for the first time.
func _ready():
	$animated_sprite.play("fly")
	pass # Replace with function body.

func _process(delta):
	if is_on_wall():
		move_direction *= -1
		
	pass
