extends Node

# HIGH SCORE
func _on_Map_score_changed():
	pass

func _on_Map_personal_best_changed():
	pass

# UI
var PlayerStats = preload("res://interface/PlayerStats.tscn")
var player_stats

# LEVEL
onready var main_menu = $MainMenu
onready var pause_menu = $UI/PauseMenu
onready var level = get_node('/root/Game/Level')
onready var game_over_menu = $UI/GameOverScreen

# SAVE
onready var _save_slot_popup = $UI/SavesPopup
#onready var transition = $UI/Transition

# SHOP AND INVENTORY
onready var ShopMenu = preload("res://interface/shop/ShopMenu.tscn")
onready var InventoryMenu = preload("res://interface/inventory-menu/InventoryMenu.tscn")
var inventory_opened = false

# PLAYER STATS UI
#onready var _player_stats = $UI/PlayerStats
#onready var _exp_bar = $UI/PlayerStats/ExperienceBar
#onready var _hp_bar = $UI/PlayerStats/HealthBar
#onready var _music_bar = $UI/PlayerStats/MusicBar
#onready var _score_label = $UI/PlayerStats/Score
#onready var _effect_time_label = $UI/PlayerStats/EffectTime

onready var _settings_menu = $UI/SettingsMenu


func _ready():
	main_menu.initialize()
	main_menu.open()
	player_stats = PlayerStats.instance()
	$UI.add_child(player_stats)
	_save_slot_popup.initialize()


func initialize_level():
	level.initialize()
	player_stats.show()
	_connect_signals()
	player_stats.initialise()
	print(level.map.get_filename())

#func _initialize_player_stats_ui(player):
#	_exp_bar.initialize(player.experience, player.experience_required, [player])
#	_hp_bar.initialize(player.get_node("Health").health, player.get_node("Health").max_health, [player])
#	_music_bar.initialize(player.current_music, player.max_music, [player])

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

func save_game(save_slot):
	if save_slot == 0:
		get_tree().paused = false
		return
	$SaveAndLoad.save_game(save_slot)
	get_tree().paused = false
	print("It should have saved")

func load_game(save_slot):
	player_stats.free()
	if save_slot == 0:
		get_tree().paused = false
		return
	player_stats = PlayerStats.instance()
	$UI.add_child(player_stats)
	change_level(level.map.get_filename())
	print("Player before load: " + str(level.player))
	$SaveAndLoad.load_game(save_slot)
	print("Player: " + str(level.player))
	player_stats.show()
	get_tree().paused = false
#	print(level.path)
	assert level.player.is_in_group("player")
	level.reset_player_position()
	player_stats.initialise()

func _input(event):
	if event.is_action_pressed("quick_save"):
		get_tree().paused = true
		save_game(yield(_save_slot_popup.open(), "completed"))
	if event.is_action_pressed("quick_load"):
		get_tree().paused = true
		load_game(yield(_save_slot_popup.open(), "completed"))

func pause():
	get_tree().paused = true
	pause_menu.open()
	yield(pause_menu, "closed")
	get_tree().paused = false

func quit_to_main_menu():
	level.set("using_strength_potion", false)
	level.player.queue_free()
	level.map.queue_free()
	level.map = null
	player_stats.hide()
	main_menu.open()

func open_inventory():
	if not $Level/Player.has_node("Inventory"):
		return
	var inventory = $Level/Player.get_node("Inventory")
	var inventory_menu = InventoryMenu.instance()
	$UI.add_child(inventory_menu)
	inventory_menu.initialize([inventory, $Level/Player])
	inventory_menu.open()

	get_tree().paused = true
	yield(inventory_menu, "closed")
	inventory_opened = false
	get_tree().paused = false

func _on_player_opened_inventory():
	if not inventory_opened:
		inventory_opened = true
		open_inventory()

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

func _on_Player_died():
	get_tree().paused = true
	game_over_menu.open()
	yield(game_over_menu, "closed")
	get_tree().paused = false