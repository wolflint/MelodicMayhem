extends Area2D

signal shop_open_requested(shop, user)

const Player = preload("res://player/player.gd")

func _ready():
	$anim.play("idle")

func _input(event):
	if not event.is_action_pressed("interact"):
		return
	for body in get_overlapping_bodies():
		if body is Player:
			emit_signal("shop_open_requested", $Shop, body)
			get_tree().set_input_as_handled()
