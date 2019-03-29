extends KinematicBody2D

signal died(experience_to_give)

# Experience
export(float) var experience_to_give = 50.0

const GRAVITY_VEC = Vector2(0, 900)
const FLOOR_NORMAL = Vector2(0, -1)

const WALK_SPEED = 70
const STATE_WALKING = 0
const STATE_KILLED = 1

var linear_velocity = Vector2()
var direction = -1
var anim=""

var state = STATE_WALKING

onready var LEVEL_ROOT = get_tree().get_root().get_node("test")
onready var detect_floor_left = $detect_floor_left
onready var detect_wall_left = $detect_wall_left
onready var detect_floor_right = $detect_floor_right
onready var detect_wall_right = $detect_wall_right
onready var sprite = $sprite
onready var player = preload("res://characters/player/player.tscn")
onready var coin = preload("res://collectibles/coin/coin.tscn")

func _ready():
	$anim.play("SETUP")
	connect("died", LEVEL_ROOT, "_on_enemy_died", [experience_to_give])
#	state = STATE_KILLED

func _physics_process(delta):
	var new_anim = "idle"

	if state == STATE_WALKING:
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
		linear_velocity = move_and_slide(linear_velocity, FLOOR_NORMAL)
		sprite.scale.x = direction
		new_anim = "explode"

	if anim != new_anim:
		anim = new_anim
		$anim.play(anim)

func hit_by_bullet():
	if state != STATE_KILLED:
		state = STATE_KILLED
		emit_signal("died")
		var new_coin = coin.instance()
		new_coin.position = position
		LEVEL_ROOT.add_child(new_coin)
	
	
	
func check_collisions():
	if get_slide_count() > 0:
				var body = get_slide_collision(0).collider
#				print(body.get_name())
				if body.get_name() == "player":
					body.take_damage(self, 1)