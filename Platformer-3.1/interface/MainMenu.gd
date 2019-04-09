extends Control

var START_GAME_SCENE = "res://level/Game.tscn"
onready var buttons = $MarginContainer/VBoxContainer/Buttons.get_children()

func _ready():
	initialize()

func initialize():
	for button in buttons:
		button.connect("pressed", self, ("_on_" + button.name + "_pressed"))

func _on_Continue_pressed():
	print("Continue")

func _on_NewGame_pressed():
	get_tree().change_scene(START_GAME_SCENE)

func _on_LoadGame_pressed():
	print("LoadGame")

func _on_Options_pressed():
	print("Options")

func _on_Controls_pressed():
	print("Controls")

func _on_Quit_pressed():
	print("Quit")