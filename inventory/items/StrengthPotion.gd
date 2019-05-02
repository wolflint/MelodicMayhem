extends "Item.gd"

export (int) var strength_multiplier
export (float) var effect_duration

func _apply_effect(user):
	user.apply_strength_potion(strength_multiplier, effect_duration)