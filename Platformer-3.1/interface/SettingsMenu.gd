extends Panel

signal open()
signal closed()

var is_fullscreen = false

# Buttons
onready var _fullscreen_btn = get_node("VBoxContainer/Buttons/Fullscreen")
onready var _soundmute_btn = get_node("VBoxContainer/Buttons/SoundMute")
onready var buttons = get_node("VBoxContainer/Buttons").get_children()

onready var GAME = get_tree().get_root().get_node("Game")

func _ready():
	set_process_input(false)

func open():
	buttons[0].grab_focus()
	emit_signal("open")
	set_process_input(true)
	show()

func close():
	emit_signal("closed")
	set_process_input(false)
	hide()

func _on_Fullscreen_pressed() -> void:
		OS.window_fullscreen = !OS.window_fullscreen
		is_fullscreen = !is_fullscreen
		_fullscreen_btn.text = "Fullscreen: " + str(is_fullscreen)



func _on_SoundMute_pressed() -> void:
	pass # Replace with function body.


func _on_Back_pressed() -> void:
	GAME.get_node("MainMenu").open()
	close()
