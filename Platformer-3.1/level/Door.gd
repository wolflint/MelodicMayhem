extends Area2D

signal player_entered(map_path)

export(String, FILE, ".tscn") var map_path
#var player = preload("res://characters/player/player.gd")

func _ready():
	assert map_path != ""

func _on_body_entered(body):
	if not body.is_in_group("player"):
		print(body.name + " is not in group player")
		return
	print(body.name)
	emit_signal("player_entered", map_path)