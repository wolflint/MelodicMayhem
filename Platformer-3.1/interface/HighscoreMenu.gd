extends Control

onready var text_box = $Panel/VBoxContainer/TextEdit

func _ready():
	HighScoreSystem.add_highscore("map_name", "player", 100)
	HighScoreSystem.add_highscore("map_name", "player2", 100)
	HighScoreSystem.add_highscore("map_name", "player3", 100)
	HighScoreSystem.add_highscore("map_name", "player4", 100)
	HighScoreSystem.add_highscore("map_name", "player5", 100)
	HighScoreSystem.add_highscore("map_name", "player6", 100)
	HighScoreSystem.add_highscore("map_name", "player7", 100)
	HighScoreSystem.add_highscore("map_name", "player8", 100)
	HighScoreSystem.add_highscore("map_name", "player9", 100)
	HighScoreSystem.add_highscore("map_name", "player10", 100)
	HighScoreSystem.add_highscore("map_name", "player11", 100)
	HighScoreSystem.add_highscore("map_name", "player12", 100)
	HighScoreSystem.add_highscore("map_name", "player13", 100)
	HighScoreSystem.add_highscore("map_name", "player14", 100)
	HighScoreSystem.add_highscore("map_name", "player15", 100)
	HighScoreSystem.add_highscore("map_name2", "player", 100)
	HighScoreSystem.add_highscore("map_name2", "player2", 100)
	initialize()

func initialize():
	var highscore_text = ""
	for level in HighScoreSystem.highscores.keys():
		if level == "Names":
			continue
		highscore_text += "Level Name: " + str(level) + "\n"
		for key in HighScoreSystem.highscores[level].keys():
			highscore_text += str(key) + ": " + str(HighScoreSystem.highscores[level][key]) + "\n"
		highscore_text += "\n\n"
	print(highscore_text)
	text_box.text = highscore_text