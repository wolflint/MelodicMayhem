extends Panel

signal open()
signal closed()

onready var buttons = $MarginContainer/Buttons.get_children()
onready var _save_slot_popup = $SavesPopup

func _ready():
	initialize()
	set_process_input(false)

func initialize():
	for button in buttons:
		button.connect("pressed", self, ("_on_" + button.name + "_pressed"))

func open():
	emit_signal("open")
	set_process_input(true)
	buttons[0].grab_focus()
	show()

func close():
	emit_signal("closed")
	set_process_input(false)
	hide()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		close()

func _on_Save_pressed():
	print("Save")

func _on_Load_pressed():
	print("Load")

func _on_QuitToMenu_pressed():
	get_node("/root/Game").quit_to_main_menu()
	close()

func _on_QuitToDesktop_pressed():
	get_tree().quit()