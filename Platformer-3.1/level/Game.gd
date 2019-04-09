extends Node

# LEVEL
onready var main_menu = $MainMenu
onready var level = $Level

# SAVE
onready var _save_slot_popup = $UI/SavesPopup
#onready var transition = $UI/Transition

# SHOP AND INVENTORY
onready var ShopMenu = preload("res://interface/shop/ShopMenu.tscn")
onready var InventoryMenu = preload("res://interface/inventory-menu/InventoryMenu.tscn")

# PLAYER STATS UI
onready var _player_stats = $UI/PlayerStats
onready var _exp_bar = $UI/PlayerStats/ExperienceBar
onready var _hp_bar = $UI/PlayerStats/HealthBar
onready var _music_bar = $UI/PlayerStats/MusicBar

var save_id = 1

func _ready():
	main_menu.initialize()
	_save_slot_popup.initialize()


func initialize_level():
	level.initialize()
	_player_stats.show()
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
	get_tree().paused = true
	level.change_level(scene_path)
	_connect_signals()
	get_tree().paused = false

func save_game():
	get_tree().paused = true
	var save_slot = yield(_save_slot_popup.open(), "completed")
	if save_slot == 0:
		get_tree().paused = false
		return
	$SaveAndLoad.save_game(save_slot)
	get_tree().paused = false
	print("It should have saved")

func load_game():
	get_tree().paused = true
	var save_slot = yield(_save_slot_popup.open(), "completed")
	if save_slot == 0:
		get_tree().paused = false
		return
	change_level(level.map.get_filename())
	$SaveAndLoad.load_game(save_slot)
	get_tree().paused = false
	level.reset_player_position()
	assert level.player.is_in_group("player")
	_initialize_player_stats_ui(level.player)

func _input(event):
	if event.is_action_pressed("open_inventory"):
		open_inventory()
	if event.is_action_pressed("quick_save"):
		save_game()
	if event.is_action_pressed("quick_load"):
		load_game()


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
	call_deferred("change_level", target_map)

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