extends Node

export(String, FILE, "*.tscn") var LEVEL_START = "res://level/TestLevel.tscn"
export(PackedScene) var Player = preload("res://characters/player/player.tscn")

var map
var player

func initialize():
	player = Player.instance()
	change_level(LEVEL_START)
	add_child(player)

func change_level(scene_path):
	if map:
		map.queue_free()
	map = load(scene_path).instance()
	add_child(map)
	move_child(map, 0)

func get_doors():
	return