extends "StatBar.gd"
var _player

func initialize(current, maximum, args = [player]):
	_player = args[0]
	_player.connect("experience_gained", self, "_on_Player_experience_gained")
	.initialize(current, maximum)
	_update_label(_player.level, current, maximum)

#func animate_value(target, tween_duration=1.0):
#	.animate_value(target, tween_duration)

func _update_label(level, current, maximum):
	$Label.text = "LVL %s - EXP %s/%s" % [level, current, maximum]

func _on_Player_experience_gained(growth_data, player):
	for line in growth_data:
		var target_exp = line[0]
		var max_exp = line[1]
		max_value = max_exp
		_update_label(player.level, target_exp, max_exp)
		yield(animate_value(target_exp), "completed")
		if abs(max_value - value) < 0.01:
			value = 0.0
