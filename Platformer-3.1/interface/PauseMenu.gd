extends Panel

signal open()
signal closed()

onready var GAME = get_tree().get_root().get_node("Game")
onready var SAVE = GAME.get_node("SaveAndLoad")
onready var buttons = $MarginContainer/Menu/Buttons.get_children()
onready var _save_slot_popup = $SavesPopup
onready var playtime_lbl = $MarginContainer/Menu/PlayTime
onready var HighScoreMenu = preload("res://interface/HighscoreMenu.tscn")

func _ready():
	initialize()
	set_process_input(false)

func initialize():
	for button in buttons:
		button.connect("pressed", self, ("_on_" + button.name + "_pressed"))
	_save_slot_popup.initialize()

func open():
	if SAVE.get_play_time():
		playtime_lbl.text = SAVE.get_play_time()
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
	var focus_owner = get_focus_owner()
	var save_slot = yield(_save_slot_popup.open(), "completed")
	if save_slot == 0:
		focus_owner.grab_focus()
	else:
		get_node("/root/Game").save_game(save_slot)
		close()

func _on_Load_pressed():
	var focus_owner = get_focus_owner()
	var save_slot = yield(_save_slot_popup.open(), "completed")
	if save_slot == 0:
		focus_owner.grab_focus()
	else:
		GAME.initialize_level()
		GAME.load_game(save_slot)
		close()

func _on_HighScores_pressed():
	var highscore_menu = HighScoreMenu.instance()
	add_child(highscore_menu)
	highscore_menu.initialize()
	highscore_menu.open()

func _on_QuitToMenu_pressed():
	get_node("/root/Game").quit_to_main_menu()
	close()

func _on_QuitToDesktop_pressed():
	get_tree().quit()
