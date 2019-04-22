extends Panel

signal open()
signal closed()

var START_GAME_SCENE = "res://level/Game.tscn"
onready var buttons = $VBoxContainer/Buttons.get_children()
onready var _save_slot_popup = $VBoxContainer/Buttons/LoadGame/SavesPopup

func _ready():
	initialize()
	set_process_input(false)

func initialize():
	for button in buttons:
		button.connect("pressed", self, ("_on_" + button.name + "_pressed"))
	_save_slot_popup.initialize()

func open():
	buttons[0].grab_focus()
	emit_signal("open")
	set_process_input(true)
	show()

func close():
	emit_signal("closed")
	set_process_input(false)
	hide()

func _on_LoadGame_pressed():
	var focus_owner = get_focus_owner()
	var save_slot = yield(_save_slot_popup.open(), "completed")
	if save_slot == 0:
		focus_owner.grab_focus()
	else:
		get_node("/root/Game").initialize_level()
		get_node("/root/Game").load_game(save_slot)
		close()

#func _on_MainMenu_pressed():
#	print("main")
#	get_node("/root/Game").quit_to_main_menu()
#	close()

func _on_Quit_pressed():
	print("quit")
	get_tree().quit()