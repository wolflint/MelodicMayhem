extends Area2D

signal player_entered(map_path)

onready var GAME = get_tree().get_root().get_node("Game")
onready var LEVEL = GAME.get_node("Level")
onready var MAP = LEVEL.get_node("Map")

export(String, FILE, ".tscn") var map_path
#var player = preload("res://characters/player/player.gd")

func _ready():
	assert map_path != ""

func _on_body_entered(body):
	HighScoreSystem.add_highscore(MAP.name, 'player', MAP.score)
	if not body.is_in_group("player"):
		return
	print(body.name)
	emit_signal("player_entered", map_path)