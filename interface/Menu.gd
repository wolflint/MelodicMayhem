extends Control

signal open()
signal closed()

export(NodePath) var SUB_MENU_PATH

func _ready():
	set_process_input(false)

#warning-ignore:unused_argument
func open():
	emit_signal("open")
	set_process_input(true)
	show()

func close():
	emit_signal("closed")
	set_process_input(false)
	hide()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		close()

func initialize(args=[]):
	return

func open_sub_menu(menu, args=[]):
	var sub_menu = menu.instance()
	if SUB_MENU_PATH:
		get_node(SUB_MENU_PATH).add_child(sub_menu)
	else:
		add_child(sub_menu)
	sub_menu.initialize(args)

	set_process_input(false)
	sub_menu.open()
	yield(sub_menu, "closed")
	set_process_input(true)
