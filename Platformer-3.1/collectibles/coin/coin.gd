extends Area2D

var taken=false

func _on_coin_body_enter( body ):
	if not taken and body is preload("res://characters/player/player.gd"):
		$anim.play("taken")
		taken = true
