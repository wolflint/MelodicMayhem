extends KinematicBody2D

signal died(experience_to_give)

# ENEMY STATS
export(float) var experience_to_give = 50.0
export(int) var strength = 1


const GRAVITY_VEC = Vector2(0, 900)
const FLOOR_NORMAL = Vector2(0, -1)

const WALK_SPEED = 140

var linear_velocity = Vector2()
var direction = -1
var anim=""

enum States {WALKING, DIED}
var state = States.WALKING

onready var GAME_ROOT = get_tree().get_root().get_node("Game")
onready var hp = $Health
onready var hitbox = $Hitbox/CollisionPolygon2D
onready var detect_floor_left = $detect_floor_left
onready var detect_wall_left = $detect_wall_left
onready var detect_floor_right = $detect_floor_right
onready var detect_wall_right = $detect_wall_right
onready var sprite = $sprite
#warning-ignore:unused_class_variable
onready var player = preload("res://characters/player/player.tscn")
export (PackedScene) var coin

func _ready():
	$anim.play("SETUP")
	connect("died", GAME_ROOT, "_on_enemy_died", [experience_to_give])
	$HookableHealthBar.initialize($Health.health, $Health.max_health, [])

func _physics_process(delta):
	var new_anim = "idle"

	if state == States.WALKING:
		linear_velocity += GRAVITY_VEC * delta
		linear_velocity.x = direction * WALK_SPEED
#		var collider = move_and_collide(linear_velocity)
#		if collider != null:
#			if collider == player:
#				collider.get_node("Health").take_damage(1)
		linear_velocity = move_and_slide(linear_velocity, FLOOR_NORMAL)
		check_collisions()

		if not detect_floor_left.is_colliding() or detect_wall_left.is_colliding():
			direction = 1.0

		if not detect_floor_right.is_colliding() or detect_wall_right.is_colliding():
			direction = -1.0

		sprite.scale = Vector2(direction, 1.0)
		new_anim = "walk"
	else:
		linear_velocity += GRAVITY_VEC * delta
		linear_velocity.x = -direction * (float(WALK_SPEED) / 2)		
		linear_velocity = move_and_slide(linear_velocity, FLOOR_NORMAL)
		sprite.scale.x = -direction
		new_anim = "explode"

	if anim != new_anim:
		anim = new_anim
		$anim.play(anim)

func drop_coin():
	print(position)
	var new_coin = coin.instance()
	new_coin.set("position", position)
	print("new_coin:")
	print(new_coin.position)
	get_parent().add_child(new_coin)

func check_collisions():
	if get_slide_count() > 0:
				var body = get_slide_collision(0).collider
				if body.get_name() == "player":
					body.take_damage(self, 1)

func _on_Hitbox_body_entered(body):
	if body.is_in_group("projectiles"):
		_take_damage(body.strength)
	if hp.health < hp.max_health:
		$HookableHealthBar.set("visible", true)

func _take_damage(amount):
	if state != States.DIED:
		hp.take_damage(amount)
	if hp.health <= 0:
		hitbox.set_deferred("disabled", true)
		set_deferred("state", States.DIED)
		call_deferred("drop_coin")
		emit_signal("died")
