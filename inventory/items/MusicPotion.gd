extends "Item.gd"

export (int) var restore_value

func _apply_effect(user):
	user.restore_music(restore_value)
