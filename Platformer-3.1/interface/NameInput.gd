extends PopupPanel

signal name_changed(new_name)

# If input from lineEdit node is empty, return, else set the player name and emit the name_changed signal
func _on_LineEdit_text_entered(new_text):
	if new_text == "":
		return
#	get_parent().set("PLAYER_NAME", new_text)
	emit_signal("name_changed", new_text)
