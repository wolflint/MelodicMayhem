extends Node

signal health_changed

var health = 0
export(int) var max_health = 1

var status = null
enum STATUSES { NONE, INVINCIBLE }

func _ready():
	health = max_health

func _change_status(new_status):
	status = new_status

func take_damage(amount):
	if status == STATUSES.INVINCIBLE:
		return
	health -= amount
	health = max(0, health)
	emit_signal("health_changed", health)

func heal(amount):
	health += amount
	health = min(health, max_health)
	emit_signal("health_changed", health)

func _on_Player_gained_max_health():
	randomize()
	var rand_amount = randi() % 4
	set("max_health", get("max_health") + rand_amount)
	set("health", get("health") + rand_amount)