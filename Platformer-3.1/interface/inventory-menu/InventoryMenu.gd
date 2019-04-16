extends "res://interface/Menu.gd"

signal item_use_requested(item, actor)

export(PackedScene) var ItemButton

onready var _item_grid = $VBox/ItemsList/Margin/Grid
onready var _description_label = $VBox/DescriptionPanel/Margin/Label
var character

func initialize(args = [inventory, character]):
	var inventory = args[0]
	character = args[1]

	for item in inventory.get_items():
		var item_button = create_item_button(item)
		item_button.connect("focus_entered", self, "_on_ItemButton_focus_entered")
		item_button.connect("pressed", self, "_on_ItemButton_pressed", [item])

	_item_grid.initialize()
	if _item_grid.get_child_count() > 0:
		_item_grid.get_child(0).grab_focus()
	inventory.connect("item_added", self, "create_item_button")
	connect("item_use_requested", inventory, "use")

func close():
	.close()
	print("close")
	queue_free()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		print("ui_cancel")
		close()


func create_item_button(item):
	var item_button = ItemButton.instance()
	item_button.initialize(item)
	_item_grid.add_child(item_button)
	return item_button

func _on_ItemButton_focus_entered():
	_description_label.text = get_focus_owner().description

func _on_ItemButton_pressed(item):
	var button = get_focus_owner()
	button.grab_focus()
	emit_signal("item_use_requested", item, character)
