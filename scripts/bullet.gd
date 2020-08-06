extends Area2D

class_name bullet

var bullet_speed = 400
var bullet_dmg = 25
var bullet_master
var bullet_direction = 1

var hitted = false
var free_time = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	$particles.direction = -bullet_direction
	pass # Replace with function body.

func _process(delta):
	if not game_config.pause:
		if not hitted:
			position += bullet_speed * bullet_direction * delta
		else:
			if free_time < 0:
				queue_free()
			else:
				free_time -= delta
	
func hit():
	hitted = true
	$particles.spread = 90
	$particles.explosiveness = 0.9
	$particles.one_shot = true
	$particles.restart()
	$Sprite.hide()
	$CollisionShape2D.set_deferred("disabled", true)
	pass

func _on_bullet_area_entered(area):
	if not area.get_network_master() == bullet_master:
		hit()
	if area.is_in_group("enemy"):
		hit()
	pass # Replace with function body.

func _on_bullet_body_entered(body):
	if body.name == "map":
		hit()
	pass # Replace with function body.
