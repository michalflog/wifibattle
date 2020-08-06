extends CanvasLayer

export (Texture) var lifeOutline

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func delete_life(id):
	var life_texture = $players_lifes.get_node(str(id) + "/lifes/" + str(multi_game.players_alife[id].lifes))
	life_texture.texture = lifeOutline
	pass

func delete_player_lifes(id):
	var player_lifes = get_node("players_lifes/" + str(id))
	player_lifes.queue_free()
	pass
