extends Node

signal score_changed(new_score)

export(String, FILE, "*.tscn") var LEVEL_START = "res://level/maps/Home.tscn"
export(PackedScene) var Player = preload("res://characters/player/player.tscn")

var map
var player
var score = 0

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
	emit_signal("score_changed", score)	
	assert player
	player.global_position = spawn.global_position

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


func _on_player_out_of_bounds():
	reset_player_position()

func _on_enemy_died(points):
	score += points
	HighScoreSystem.add_highscore(map.MAP_NAME, player.PLAYER_NAME, score)
	emit_signal("score_changed", score)
	print(HighScoreSystem.highscores)