extends "StatBar.gd"

func initialize(current, maximum, args = []):
	var player = args[0]
	player.connect("music_level_changed", self, "_on_Player_music_level_changed")
	.initialize(current, maximum)
	_update_label(current, maximum)

#func animate_value(target, tween_duration=1.0):
#	.animate_value(target, tween_duration)

func _update_label(current, maximum):
	$Label.text = "MUSIC %s/%s" % [current, maximum]

#func _on_Player_experience_gained(growth_data, player):
#	for line in growth_data:
#		var target_exp = line[0]
#		var max_exp = line[1]
#		max_value = max_exp
#		_update_label(player.level, target_exp, max_exp)
#		yield(animate_value(target_exp), "completed")
#		if abs(max_value - value) < 0.01:
#			value = 0.0


func _on_Player_music_level_changed(current_music, max_music):
	set("max_value", max_music)
	yield(animate_value(current_music), "completed")
	_update_label(current_music, max_music)
