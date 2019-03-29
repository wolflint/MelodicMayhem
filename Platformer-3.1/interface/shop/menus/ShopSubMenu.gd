extends "res://interface/Menu.gd"

export(String, "sell_to", "buy_from") var ACTION

onready var _items_list = $Row/ShopItemsList
onready var _description_panel = $DescriptionPanel
onready var _info_panel = $Row/InfoPanel
onready var _amount_popup = _items_list.get_node("AmountPopup")


func initialize(args = [shop, buyer, items]):
	var shop = args[0]
	var buyer = args[1]
	var items = args[2]
	
	for item in items:
		var price = shop.get_buy_value(item) if ACTION == "buy_from" else item.price
		var item_button = _items_list.add_item_button(item, price)

		item_button.connect("pressed", self, "_on_ItemButton_pressed", [shop, buyer, item])
		item_button.connect("pressed", _info_panel, "_on_focused_Item_amount_changed", [item])
	_items_list.connect("focused_button_changed", self, "_on_ItemList_focused_button_changed")
	_items_list.initialize()

	_info_panel.initialize(buyer.get_node("Purse"))

func _on_ItemList_focused_button_changed(item_button):
	_description_panel.display(item_button.description)

func open():
	.open()
	_items_list.get_child(0).grab_focus()

func close():
	.close()
	queue_free()

func _on_ItemButton_pressed(shop, buyer, item):
	assert item != null
	var focused_item = get_focus_owner()
	_amount_popup.initialize([1, item.amount])
	var amount = yield(_amount_popup.open(), "completed")
	focused_item.grab_focus()
	if not amount:
		return
	shop.call(ACTION, buyer, item, amount)
