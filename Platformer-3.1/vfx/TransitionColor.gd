extends ColorRect

signal transition_finished()

onready var anim_player = $AnimationPlayer

func fade_to_color():
	_transition("to_color")

func fade_from_color():
	_transition("to_transparent")

func _transition(anim_name):
	show()
	anim_player.play(anim_name)
	yield(anim_player, "animation_finished")
	hide()
	emit_signal("transition_finished")
