extends HBoxContainer

func _ready():
	pass

func set_properties(char_id):
	var char_prop = game_config.characters[char_id]
	var blue : Color = Color("#10446d")
	var white : Color = Color(1, 1, 1)
	
	for v in range(3):
		if v <= char_prop.health - 1:
			find_node("health").find_node(String(v)).modulate = blue
		else:
			find_node("health").find_node(String(v)).modulate = white
			
		if v <= char_prop.speed - 1:
			find_node("speed").find_node(String(v)).modulate = blue
		else:
			find_node("speed").find_node(String(v)).modulate = white
			
		if v <= char_prop.damage - 1:
			find_node("damage").find_node(String(v)).modulate = blue
		else:
			find_node("damage").find_node(String(v)).modulate = white
		
	pass
