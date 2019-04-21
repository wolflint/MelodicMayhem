extends PopupPanel

signal name_changed()

func _ready():
#	popup_centered()
#	get_tree().get_root().set_disable_input(true)
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		if $VBoxContainer/LineEdit.text == "":
			return
		get_parent().set("PLAYER_NAME", $VBoxContainer/LineEdit.text)
		emit_signal("name_changed")
#		get_tree().get_root().set_disable_input(false)