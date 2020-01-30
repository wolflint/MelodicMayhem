extends "res://interface/Menu.gd"

signal save_slot_selected(id)

onready var amount_popup = self
onready var save_slots = $SaveSlots.get_children()

func initialize(args = []):
	for slot in save_slots:
		slot.connect("pressed", self, ("_on_" + slot.name + "_pressed"))


func open():
	amount_popup.popup_centered()
	.open()
	save_slots[0].grab_focus()
	var save_id = yield(self, "save_slot_selected")
	close()
	return save_id

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		emit_signal("save_slot_selected", 0)
		get_tree().set_input_as_handled()

func _on_Slot1_pressed():
	emit_signal("save_slot_selected", 1)

func _on_Slot2_pressed():
	emit_signal("save_slot_selected", 2)


func _on_Slot3_pressed():
	emit_signal("save_slot_selected", 3)

func _on_Slot4_pressed():
	emit_signal("save_slot_selected", 4)


