extends Node

signal game_saved()
signal game_loaded()

const SAVE_DIRECTORY = "user://save/"
const SAVE_FILE_EXT = ".game"

var playtime = 0

func _ready():
	connect("game_loaded", get_node('/root/Game/Level'), "_on_game_loaded")

func save_game(id):
	HighScoreSystem.save_scores()
	var save_data = {
		"version": ProjectSettings.get_setting("application/config/Version"),
		"playtime": playtime,
		"data": [],
	}
	for node in get_tree().get_nodes_in_group("save"):
		var node_data = node.get_save_data()
		assert node_data["filename"] != ""
		assert node_data["parent"] != ""
		save_data['data'].append(node_data)

	var directory = Directory.new()
	if not directory.dir_exists(SAVE_DIRECTORY):
		directory.make_dir_recursive(SAVE_DIRECTORY)

	var path = get_save_file_path(id)
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(to_json(save_data))
	file.close()
	emit_signal("game_saved")

func load_game(id):
	HighScoreSystem.load_scores()
	var path = get_save_file_path(id)
	var file = File.new()
	if not file.file_exists(path):
		print("Couldn't load file %s: doesn't exist" % path)
		return
	file.open(path, File.READ)
	var save_data = parse_json(file.get_as_text())
	file.close()
	
	playtime = save_data["playtime"]
	
	for node in get_tree().get_nodes_in_group("save"):
		node.free()

	for node_data in save_data['data']:
		var node = load(node_data['filename']).instance()
		get_node(node_data['parent']).add_child(node)
		var properties = node_data['properties']
		for property in properties.keys():
			var value
			if is_vector_2(property, node):
				value = parse_vector_2(properties[property])
			elif property == "_purse.coins":
				node._purse.coins = properties[property]
			elif property == "health.max_health":
				node.health.max_health = properties[property]
			else:
				value = properties[property]
			node.set(property, value)
	emit_signal("game_loaded")

func get_play_time():
	var current_playtime = int(playtime)
	
	var day = int(current_playtime / (24 * 3600))
	
	current_playtime = current_playtime % (24 * 3600)
	var hour = current_playtime / 3600
	
	current_playtime %= 3600
	var minutes = current_playtime / 60
	
	current_playtime %= 60
	var seconds = current_playtime
	
	print(day)
	print(hour)
	print(minutes)
	return (str(day) + " d " + str(hour) + " h " + str(minutes) + " m " + str(seconds) + " s ")

func _on_Timer_timeout():
	playtime += 1

func is_vector_2(property_name, node):
	return typeof(node.get(property_name)) == typeof(Vector2())

func parse_vector_2(json_string):
	var numbers_string = json_string.substr(1, len(json_string) - 1)
	var comma_position = numbers_string.find(",")
	var value_x = float(numbers_string.left(comma_position))
	var value_y = float(numbers_string.right(comma_position + 1))
	return Vector2(value_x, value_y)

func get_save_file_path(id):
	return SAVE_DIRECTORY + str(id) + SAVE_FILE_EXT