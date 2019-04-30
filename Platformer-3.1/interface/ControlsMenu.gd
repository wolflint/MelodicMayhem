extends "res://interface/Menu.gd"

var controls_text = ""

func initialize(args = []):
	for level in HighScoreSystem.highscores.keys():
		if level == "Names":
			continue
		highscore_text += "Level Name: " + str(level) + "\n"
		for key in HighScoreSystem.highscores[level].keys():
			highscore_text += str(key) + ": " + str(HighScoreSystem.highscores[level][key]) + "\n"
		highscore_text += "\n\n"
	print(highscore_text)

func open():
	.open()
	get_tree().paused = true
	$Panel/VBoxContainer/TextEdit.set("text", highscore_text)

func close():
	get_tree().paused = false
	.close()