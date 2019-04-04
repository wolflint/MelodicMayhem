extends "StatBar.gd"

func initialize(current, maximum, args = []):
	.initialize(current, maximum)
#	_update_label(current, maximum)

#func _update_label(current, maximum):
#	$Label.text = "HP %s/%s" % [current, maximum]

func _on_Health_health_changed(health):
	if health < 1:
		set("visible", false)
	yield(animate_value(health), "completed")
