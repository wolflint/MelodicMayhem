extends Node

const SAVE_DIRECTORY = "user://save/"
const SAVE_FILE_EXT = ".score"

var highscores = {}

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

func save_scores(id="highscore"):
	var save_data = {
		"version": ProjectSettings.get_setting("application/config/Version"),
		"data": [],
	}

	var directory = Directory.new()
	if not directory.dir_exists(SAVE_DIRECTORY):
		directory.make_dir_recursive(SAVE_DIRECTORY)

	var path = get_save_file_path(id)
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(to_json(highscores))
	file.close()

func load_scores(id="highscore"):
	var path = get_save_file_path(id)
	var file = File.new()
	if not file.file_exists(path):
		print("Couldn't load file %s: doesn't exist" % path)
		return
	file.open(path, File.READ)
	highscores = parse_json(file.get_as_text())
	file.close()
	print(highscores)


func get_save_file_path(id="highscore"):
	return SAVE_DIRECTORY + str(id) + SAVE_FILE_EXT