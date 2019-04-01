extends Node

onready var ShopMenu = preload("res://interface/shop/ShopMenu.tscn")
onready var _character = $player
onready var _label = $UI/Interface/Label
onready var _bar = $UI/Interface/ExperienceBar

func _ready():
	_label.update_text(_character.level, _character.experience, _character.experience_required)
	_bar.initialize(_character.experience, _character.experience_required)
	### TESTING PURPOSES - REMOVE LATER###
	_character.get_node("Purse").coins += 1000

func _input(event):
	if not event.is_action_pressed('test_experience'):
		return
	_character.gain_experience(34)
	_label.update_text(_character.level, _character.experience, _character.experience_required)

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