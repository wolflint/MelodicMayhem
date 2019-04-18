extends Node

var highscores = {}

func _ready():
	add_highscore('map1', 'marcin', 100)
	print(add_highscore('map1', 'marcin', 110))
	
	print(get_highscore('map1', 'marcin'))

func add_highscore(map_name, player : String, score : int):
	if map_name in highscores.keys():
		if player in highscores[map_name].keys():
			return "Name is already taken"
	
	highscores[map_name] = {player : score}
	print(highscores)

func get_highscore(map_name, player_name):
	if not map_name in highscores:
		return 'Map not found in database.'
	if not player_name in highscores.get(map_name).keys():
		return "Player hasn't set a high score."
	return highscores.get(map_name)[player_name]