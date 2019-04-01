extends "res://interface/Menu.gd"

export(PackedScene) var BuyMenu = preload("res://interface/shop/menus/BuySubMenu.tscn")
export(PackedScene) var SellMenu = preload("res://interface/shop/menus/BuySubMenu.tscn")

onready var _buttons = $Column/Buttons
onready var _submenu = $Column/Menu
onready var _buy_button = $Column/Buttons/BuyButton
onready var _sell_button = $Column/Buttons/SellButton

func open(args = [shop, buyer]):
	var shop = args[0]
	var buyer = args[1]
	_buy_button.connect("pressed", self, "open_submenu",
		[BuyMenu, [shop, buyer, shop.inventory]])
	_sell_button.connect("pressed", self, "open_submenu",
		[SellMenu, [shop, buyer, buyer.get_node("Inventory")]])
	_buttons.get_child(0).grab_focus()
	.open()

func close():
	queue_free()
	.close()

func open_submenu(Menu, args = [shop, buyer, inventory]):
	var shop = args[0]
	var buyer = args[1]
	var inventory = args[2]
	
	var pressed_button = get_focus_owner()
	
	var active_menu = Menu.instance()
	_submenu.add_child(active_menu)
	active_menu.initialize([shop, buyer, inventory.get_items()])
	set_process_input(false)
	active_menu.open()
	yield(active_menu, "closed")
	set_process_input(true)
	pressed_button.grab_focus()

func _on_QuitButton_pressed():
	close()
