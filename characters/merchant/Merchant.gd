extends Area2D

signal shop_open_requested(shop, user)

const Player = preload("res://characters/player/Player.gd")

func _ready():
	$anim.play("idle")

func _input(event):
	if not event.is_action_pressed("interact"):
		return
	for body in get_overlapping_bodies():
		print(body.name)
		if body is Player:
			print("is in player group")
			emit_signal("shop_open_requested", $Shop, body)
			get_tree().set_input_as_handled()
