extends Node

# LEVEL
onready var level = $Level
#onready var transition = $UI/Transition

# SHOP AND INVENTORY
onready var ShopMenu = preload("res://interface/shop/ShopMenu.tscn")
onready var InventoryMenu = preload("res://interface/inventory-menu/InventoryMenu.tscn")

# PLAYER STATS UI
onready var _exp_bar = $UI/PlayerStats/ExperienceBar
onready var _hp_bar = $UI/PlayerStats/HealthBar
onready var _music_bar = $UI/PlayerStats/MusicBar

var save_id = 1

func _ready():
	level.initialize()
	_connect_signals()
	_initialize_player_stats_ui(level.player)
	print(level.map.get_filename())

func _initialize_player_stats_ui(player):
	_exp_bar.initialize(player.experience, player.experience_required, [player])
	_hp_bar.initialize(player.get_node("Health").health, player.get_node("Health").max_health, [player])
	_music_bar.initialize(player.current_music, player.max_music, [player])

func _connect_signals():
	for door in level.get_doors():
		door.connect("player_entered", self, "_on_Door_player_entered")
	for merchant in level.get_merchants():
		merchant.connect("shop_open_requested", self, "_on_merchant_shop_open_requested")

func change_level(scene_path):
	# Pause level processing during level change
	get_tree().paused = true
#	transition.fade_to_color()
#	yield(transition, "transition_finished")
	level.change_level(scene_path)
	_connect_signals()
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
		change_level(level.map.get_filename())
		$SaveAndLoad.load_game(save_id)
		level.reset_player_position()
		assert level.player.is_in_group("player")
		_initialize_player_stats_ui(level.player)

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