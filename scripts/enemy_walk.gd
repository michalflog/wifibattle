extends enemy

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if is_on_wall():
		move_direction *= -1
	
	animation_play()
		
	pass
	
func animation_play():
	if is_on_floor():
		$animated_sprite.play("run")
	else:
		$animated_sprite.play("fall")
