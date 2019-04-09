extends Control

signal open()
signal closed()

var START_GAME_SCENE = "res://level/Game.tscn"
onready var buttons = $MarginContainer/VBoxContainer/Buttons.get_children()

func _ready():
	set_process_input(false)

func initialize():
	open()
	for button in buttons:
		if button == buttons[1]:
			button.grab_focus()
		button.connect("pressed", self, ("_on_" + button.name + "_pressed"))

func open():
	emit_signal("open")
	set_process_input(true)
	show()

func close():
	emit_signal("closed")
	set_process_input(false)
	hide()

func _on_Continue_pressed():
	print("Continue")

func _on_NewGame_pressed():
	get_parent().initialize_level()
	close()

func _on_LoadGame_pressed():
	print("LoadGame")

func _on_Options_pressed():
	print("Options")

func _on_Controls_pressed():
	print("Controls")

func _on_Quit_pressed():
	print("Quit")