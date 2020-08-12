extends Position2D

export var spawn_time = 2

var enemies = {
	enemy_walk = load("res://scenes/enemy_walk.tscn")
}

var spawn_pause = true

var wave = 0
var enemy_upgrade
var wave_set
var current_wave

var spawn_direction = 1
var current_spawn_time = 0
var current_spawned_enemies = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	signals.connect("next_wave", self, "next_wave")
	signals.connect("enemy_dead", self, "enemy_dead")
	wave_set = waves.new().waves_set
	next_wave_timer()
	pass # Replace with function body.

func _process(delta):
	if not game_config.pause and not spawn_pause:
		check_spawn_time(delta)
	pass
	
func check_spawn_time(delta):
	if current_spawn_time <= 0:
		if check_if_more_enemies_to_spawn():
			spawn_enemy()
		current_spawn_time = spawn_time
	else:
		current_spawn_time -= delta
	pass

func check_if_more_enemies_to_spawn():
	for e in current_wave.enemies:
		if e.number > 0:
			return true
	spawn_pause = true
	return false
	pass

func choose_enemy_to_spawn():
	var num = current_wave.enemies.size()
	var id = game_config.rand.randi_range(0, num - 1)
	if current_wave.enemies[id].number == 0:
		return choose_enemy_to_spawn()
	current_wave.enemies[id].number -= 1
	return {enemie = enemies[current_wave.enemies[id].name], upgrade = current_wave.enemies[id].upgrade}
	pass
	
func spawn_enemy():
	var choosed_enemie = choose_enemy_to_spawn()
	var new_enemy : enemy = choosed_enemie.enemie.instance()
	new_enemy.move_direction = Vector2(spawn_direction, 0)
	add_child(new_enemy)
	new_enemy.upgrade(wave / (wave_set.size() + 1), choosed_enemie.upgrade)
	new_enemy.update_hp_bar()
	spawn_direction *= -1
	current_spawned_enemies += 1
	pass
	
func next_wave():
	wave += 1
	var wave_num = wave
	if wave >= wave_set.size():
		wave_num = wave % wave_set.size()
		if wave_num == 0:
			wave_num = wave_set.size()
			wave_set = waves.new().waves_set
	current_wave = wave_set[wave_num]
	spawn_time = current_wave.spawn_time
	current_spawn_time = 0
	start_next_wave()
	pass
	
func start_next_wave():
	spawn_pause = false
	pass
	
func end_wave():
	next_wave_timer()
	pass
	
func enemy_dead():
	current_spawned_enemies -= 1
	check_if_more_enemies_to_spawn()
	check_end_of_wave()
	
func check_end_of_wave():
	if current_spawned_enemies == 0 and spawn_pause:
		end_wave()
	pass
	
func next_wave_timer():
	single_game.add_timer(5, "next_wave")
	pass
