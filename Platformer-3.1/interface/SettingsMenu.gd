extends Panel

var is_fullscreen = false

# Buttons
onready var _fullscreen_btn = get_node("VBoxContainer/VBoxContainer/Fullscreen")
onready var _soundmute_btn = get_node("VBoxContainer/VBoxContainer/SoundMute")

func _on_Fullscreen_pressed() -> void:
		OS.window_fullscreen = !OS.window_fullscreen
		is_fullscreen = !is_fullscreen
		_fullscreen_btn.text = "Fullscreen: " + str(is_fullscreen)



func _on_SoundMute_pressed() -> void:
	pass # Replace with function body.
