extends KinematicBody2D

signal died(experience_to_give)

# Experience
#warning-ignore:unused_class_variable
export(float) var experience_to_give = 50.0


const GRAVITY_VEC = Vector2(0, 900)
const FLOOR_NORMAL = Vector2(0, -1)

const WALK_SPEED = 140

var linear_velocity = Vector2()
var direction = -1
var anim=""

enum States {WALKING, DIED}
var state = States.WALKING

onready var GAME_ROOT = get_tree().get_root().get_node("Game")
onready var LEVEL_ROOT = GAME_ROOT.get_node("Level")
onready var hp = $Health
onready var hitbox = $Hitbox/CollisionPolygon2D
onready var detect_floor_left = $detect_floor_left
onready var detect_wall_left = $detect_wall_left
onready var detect_floor_right = $detect_floor_right
onready var detect_wall_right = $detect_wall_right
onready var sprite = $sprite
#warning-ignore:unused_class_variable
onready var player = preload("res://characters/player/player.tscn")
onready var coin = preload("res://collectibles/coin/coin.tscn")

func _ready():
	$anim.play("SETUP")
#warning-ignore:return_value_discarded
	connect("died", GAME_ROOT, "_on_enemy_died", [experience_to_give])
#	state = STATE_KILLED

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
		linear_velocity.x = -direction * (WALK_SPEED / 2)		
		linear_velocity = move_and_slide(linear_velocity, FLOOR_NORMAL)
		sprite.scale.x = -direction
		new_anim = "explode"

	if anim != new_anim:
		anim = new_anim
		$anim.play(anim)

func drop_coin():
	var new_coin = coin.instance()
	new_coin.set("position", position)
	LEVEL_ROOT.get_node("Coins").add_child(new_coin)

func check_collisions():
	if get_slide_count() > 0:
				var body = get_slide_collision(0).collider
#				print(body.get_name())
				if body.get_name() == "player":
					body.take_damage(self, 1)

func _on_Hitbox_body_entered(body):
	if body.is_in_group("projectiles"):
		_take_projectile_damage(body)


func _take_projectile_damage(projectile):
	if state != States.DIED:
		hp.take_damage(projectile.strength)
	if hp.health <= 0:
		hitbox.set_deferred("disabled", true)
#		print("died")
		set_deferred("state", States.DIED)
		call_deferred("drop_coin")
		emit_signal("died")
