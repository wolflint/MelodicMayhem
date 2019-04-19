extends Node

var highscores = {}

#func _ready():
#	add_highscore('map1', 'marcin', 100)
#	highscores['map1']['player'] = 700
#	add_highscore('map1', 'marcin', 50)
#	print(highscores)

func add_highscore(map_name, player : String, score : int):
	if not map_name in highscores.keys():
		highscores[map_name] = {player : score}
		return
	elif not player in highscores[map_name].keys():
		highscores[map_name][player] = score
		return
	elif highscores[map_name][player] < score:
		highscores[map_name][player] = score
	else:
		print("Last highscore was higher")

func get_highscore(map_name, player_name):
	if not map_name in highscores:
		return 'Map not found in database.'
	if not player_name in highscores.get(map_name).keys():
		return "Player hasn't set a high score."
	return highscores.get(map_name)[player_name]