extends Node

class_name timer

var time : int
var timer_name : String

signal second_pass

func _init(_time : int, _timer_name : String):
	time = _time
	timer_name = _timer_name
	pass
	
func start_timer():
	while time >= 0:
		second()
		yield(self, "second_pass")
	end_timer()
	pass
	
func second():
	signals.timer_time(time)
	yield(get_tree().create_timer(1.0), "timeout")
	time -= 1
	emit_signal("second_pass")
	pass
	
func end_timer():
	signals.end_timer()
	pass
	
# Called when the node enters the scene tree for the first time.
func _ready():
	start_timer()
	pass # Replace with function body.
