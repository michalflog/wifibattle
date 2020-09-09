extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	signals.connect("power_up_pop_up", self, "power_up_pop_up")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func power_up_pop_up():
	$AnimationPlayer.play("fade")
	pass

func power_up_chosen():
	$AnimationPlayer.play_backwards("fade")
	yield($AnimationPlayer, "animation_finished")
	signals.emit_signal("power_up_chosen")

func _on_dmg_pressed():
	signals.emit_signal("power_up_player", "dmg")
	power_up_chosen()

func _on_hp_pressed():
	signals.emit_signal("power_up_player", "hp")
	power_up_chosen()

func _on_f_hp_pressed():
	signals.emit_signal("power_up_flower", "hp")
	power_up_chosen()

func _on_r_f_hp_pressed():
	signals.emit_signal("power_up_flower", "recover")
	power_up_chosen()
