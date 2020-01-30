tool
extends TextureProgress

func initialize(current, maximum, args = []):
	max_value = maximum
	value = current

func animate_value(target, tween_duration=1.0):
	$Tween.interpolate_property(self, "value", value, target, tween_duration, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
