extends Node

onready var ShopMenu = preload("res://interface/shop/ShopMenu.tscn")
onready var InventoryMenu = preload("res://interface/inventory-menu/InventoryMenu.tscn")

onready var level = $Level
#onready var transition = $UI/Transition

var save_id = 1

func _ready():
	level.initialize()
	for door in level.get_doors():
		door.connect("player_entered", self, "_on_Door_player_entered")
#	current_level = level.instance()
#	add_child(current_level)

func change_level(scene_path):
	# Pause level processing during level change
	get_tree().paused = true
#	transition.fade_to_color()
#	yield(transition, "transition_finished")

	level.change_level(scene_path)
	for door in level.get_doors():
		door.connect("player_entered", self, "_on_Door_player_entered")
#	transition.fade_from_color()
#	yield(transition, "transition_finished")
	get_tree().paused = false


func _input(event):
	if event.is_action_pressed("open_inventory"):
		open_inventory()
	if event.is_action_pressed("quick_save"):
		$SaveAndLoad.save_game(save_id)
		print("It should have saved")
	if event.is_action_pressed("quick_load"):
		change_level("res://level/TestLevel.tscn")
		$SaveAndLoad.load_game(save_id)

func open_inventory():
	if not $Level/Player.has_node("Inventory"):
		return
	var inventory = $Level/Player.get_node("Inventory")
	var inventory_menu = InventoryMenu.instance()
	$UI.add_child(inventory_menu)
	inventory_menu.initialize([inventory, $Level/Player])

	get_tree().paused = true
	yield(inventory_menu, "closed")
	get_tree().paused = false

func _on_Door_player_entered(target_map):
	change_level(target_map)

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
	$Level/Player.gain_experience(34)
#	_label.update_text(_character.level, _character.experience, _character.experience_required)