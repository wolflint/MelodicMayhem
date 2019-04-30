extends Node

signal score_changed(new_score)

export(String, FILE, "*.tscn") var LEVEL_START = "res://level/maps/Home.tscn"
export(PackedScene) var Player = preload("res://characters/player/player.tscn")

var map
var player
var score = 0
var using_strength_potion = false

func _process(delta: float) -> void:
	if using_strength_potion == true:
		if player == null:
			return
		var strength_time_left = player.get_node("StrengthTimer").get_time_left()
		var effect_label = get_parent()._effect_time_label
		if not strength_time_left == 0:
			effect_label.show()
			effect_label.text = "Strength: " + str(floor(strength_time_left))
		else:
			effect_label.hide()

func initialize():
	player = Player.instance()
	player.connect("player_out_of_bounds", self, "_on_player_out_of_bounds")
	player.get_node("Purse").coins += 1000
	change_level(LEVEL_START)
	add_child(player)

func _unhandled_input(event):
	if event.is_action_pressed("pause_game"):
		get_parent().pause()
		get_tree().set_input_as_handled()

func change_level(scene_path):
	if map:
#		remove_child(map)
		map.queue_free()
	map = load(scene_path).instance()
	add_child(map)
	move_child(map, 0)

	var spawn = map.get_node("PlayerSpawningPoint")
	score = 0
	get_parent().player_stats.score_lbl.text = "Score: " + str(score)
	emit_signal("score_changed", score)
	assert player
	player.global_position = spawn.global_position
	print(player.PLAYER_NAME)

func get_doors():
	var doors = []
	for door in get_tree().get_nodes_in_group("doors"):
		if not map.is_a_parent_of(door):
			continue
		doors.append(door)
	return doors

func get_merchants():
	var merchants = []
	for merchant in get_tree().get_nodes_in_group("merchant"):
		if not map.is_a_parent_of(merchant):
			continue
		merchants.append(merchant)
	return merchants

func reset_player_position():
	var spawn = map.get_node("PlayerSpawningPoint")
	player.global_position = spawn.global_position


func _on_toggle_strength_potion():
	using_strength_potion = !using_strength_potion

func _on_player_out_of_bounds():
	reset_player_position()

func _on_score_changed(points):
	score += points
	HighScoreSystem.add_highscore(map.MAP_NAME, player.PLAYER_NAME, score)
	get_parent().player_stats.score_lbl.text = "Score: " + str(score)