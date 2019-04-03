extends Node

onready var ShopMenu = preload("res://interface/shop/ShopMenu.tscn")
onready var InventoryMenu = preload("res://interface/inventory-menu/InventoryMenu.tscn")
onready var _character = $Player
onready var _label = $UI/Interface/Label
onready var _exp_bar = $UI/PlayerStats/ExperienceBar
onready var _hp_bar = $UI/PlayerStats/HealthBar

func _ready():
	_label.update_text(_character.level, _character.experience, _character.experience_required)
	_exp_bar.initialize(_character.experience, _character.experience_required, [_character])
	_hp_bar.initialize(_character.get_node("Health").health, _character.get_node("Health").max_health)
	### TESTING PURPOSES - REMOVE LATER###
	_character.get_node("Purse").coins += 1000

func _input(event):
	if event.is_action_pressed("open_inventory"):
		open_inventory()

func open_inventory():
	if not _character.has_node("Inventory"):
		return
	var inventory = _character.get_node("Inventory")
	var inventory_menu = InventoryMenu.instance()
	$UI.add_child(inventory_menu)
	inventory_menu.initialize([inventory, _character])

	get_tree().paused = true
	yield(inventory_menu, "closed")
	get_tree().paused = false

func _on_merchant_shop_open_requested(shop, user):
	if not user.has_node("Inventory"):
		return

	var shop_menu = ShopMenu.instance()
	$UI.add_child(shop_menu)
	shop_menu.open([shop, user])

	get_tree().paused = true
	yield(shop_menu, "closed")
	get_tree().paused = false

func _on_enemy_died(experience_to_give):
	_character.gain_experience(34)
	_label.update_text(_character.level, _character.experience, _character.experience_required)