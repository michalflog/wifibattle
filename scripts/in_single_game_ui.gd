extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	signals.connect("update_flower_hp", self, "update_flower_hp")
	signals.connect("update_points", self, "update_points")
	signals.connect("update_waves", self, "update_waves")
	signals.connect("timer_time", self, "timer_time")
	pass # Replace with function body.

func update_flower_hp(hp, max_hp):
	var flower_hp_bar = find_node("flower_hp")
	if flower_hp_bar.value > hp:
		play_deal_dmg()
	flower_hp_bar.max_value = max_hp
	flower_hp_bar.value = hp
	pass

func timer_time(time):
	find_node("timer_name").text = single_game.current_timer.timer_name.replace("_", " ")
	find_node("timer").text = String(time)
	$timer_change.stop()
	$timer_change.play("timer_count")
	pass

func update_points(points):
	find_node("score").text = String(points)
	$update_score.play("update_score")
	pass
	
func update_waves(waves):
	find_node("wave_num").text = String(waves)
	pass
	
func play_deal_dmg():
	$AnimationPlayer.play("deal_dmg")
	pass
	
#func _process(delta):
#	pass
