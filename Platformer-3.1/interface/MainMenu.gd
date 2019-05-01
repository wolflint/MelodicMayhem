extends Control

signal open()
signal closed()

var START_GAME_SCENE = "res://level/Game.tscn"
onready var buttons = $MarginContainer/VBoxContainer/Buttons.get_children()
onready var _save_slot_popup = $MarginContainer/VBoxContainer/Buttons/LoadGame/SavesPopup

func _ready():
	set_process_input(false)

func initialize():
	for button in buttons:
		button.connect("pressed", self, ("_on_" + button.name + "_pressed"))
	_save_slot_popup.initialize()

func open():
	buttons[1].grab_focus()
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
	get_parent().get_node("Level").player.change_name()
	print("name change from newgame")
	close()

func _on_LoadGame_pressed():
	var focus_owner = get_focus_owner()
	var save_slot = yield(_save_slot_popup.open(), "completed")
	if save_slot == 0:
		focus_owner.grab_focus()
	else:
		get_parent().initialize_level()
		get_parent().load_game(save_slot)
		close()


func _on_Settings_pressed():
	get_parent()._settings_menu.open()
	close()

func _on_Controls_pressed():
	$ControlsMenu.open()
	yield($ControlsMenu, "closed")

func _on_Quit_pressed():
	get_tree().quit()