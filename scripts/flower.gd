extends Area2D

export var hp = 100
export var max_hp = 100

func _ready():
	pass # Replace with function body.

func deal_dmg(dmg):
	hp -= dmg
	signals.update_flower_hp(hp, max_hp)
	play_deal_dmg()
	if hp <= 0:
		signals.end_single_game()
	pass

func _on_flower_body_entered(body):
	if body.is_in_group("enemy"):
		deal_dmg(body.dmg)
		body.dead()
	pass # Replace with function body.
	
func play_deal_dmg():
	$AnimationPlayer.play("deal_dmg")
	pass
