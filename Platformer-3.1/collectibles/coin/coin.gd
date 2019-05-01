extends Area2D

signal coin_taken(coin_value)

# GAME LAYOUT
onready var GAME = get_tree().get_root().get_node("Game")
onready var LEVEL = GAME.get_node("Level")

export (int) var coin_value = 10
var taken=false

func _ready():
	connect("coin_taken", LEVEL, "_on_score_changed", [coin_value])

func _on_coin_body_enter( body ):
	if not taken and body.is_in_group("player"):
		body.get_node("Purse").coins += coin_value
		$anim.play("taken")
		taken = true
		emit_signal("coin_taken")
