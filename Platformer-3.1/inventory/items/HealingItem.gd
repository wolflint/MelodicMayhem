extends "Item.gd"

export (int) var healing_value = 5

func _apply_effect(user):
	user.get_node("Health").heal(healing_value)
	print(healing_value)