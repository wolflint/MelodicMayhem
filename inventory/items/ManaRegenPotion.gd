extends "res://inventory/items/Item.gd"

export (int) var regen_multiplier = 2
export (int) var effect_duration = 30

func _apply_effect(user):
	user.apply_mregen_potion(regen_multiplier, effect_duration)
