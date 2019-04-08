extends Node

export(String, FILE, "*.tscn") var LEVEL_START = "res://level/TestLevel.tscn"
export(PackedScene) var Player = preload("res://characters/player/player.tscn")

var map
var player

onready var _exp_bar = get_parent().get_node("UI/PlayerStats/ExperienceBar")
onready var _hp_bar = get_parent().get_node("UI/PlayerStats/HealthBar")
onready var _music_bar = get_parent().get_node("UI/PlayerStats/MusicBar")

func initialize():
	player = Player.instance()
	player.get_node("Purse").coins += 1000
	change_level(LEVEL_START)
	_initialize_player_stats_ui(player)
	add_child(player)

func change_level(scene_path):
	if map:
		map.queue_free()
	map = load(scene_path).instance()
	add_child(map)
	move_child(map, 0)

	var spawn = map.get_node("PlayerSpawningPoint")
	player.global_position = spawn.global_position
	_initialize_player_stats_ui(player)


func _initialize_player_stats_ui(new_player_instance):
	_exp_bar.initialize(new_player_instance.experience, new_player_instance.experience_required, [new_player_instance])
	_hp_bar.initialize(new_player_instance.get_node("Health").health, new_player_instance.get_node("Health").max_health)
	_music_bar.initialize(new_player_instance.current_music, new_player_instance.max_music)


func get_doors():
	var doors = []
	for door in get_tree().get_nodes_in_group("doors"):
		if not map.is_a_parent_of(door):
			continue
		doors.append(door)
	print(doors)
	return doors