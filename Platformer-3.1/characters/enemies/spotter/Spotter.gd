extends KinematicBody2D

signal died(points)

# GAME LAYOUT
onready var GAME = get_tree().get_root().get_node("Game")
onready var LEVEL = GAME.get_node("Level")
onready var MAP = LEVEL.get_child(0)

#### CONSTANTS FROM THE DEMO ENEMY ####
#const GRAVITY_VEC = Vector2(0, 900)
const GRAVITY = Vector2(0, 100)
const FLOOR_NORMAL = Vector2(0, -1)
const WALK_SPEED = 140.0
const MIN_ONAIR_TIME = 0.1
const SLOPE_SLIDE_STOP = 25.0
var onair_time = 0 #
var on_floor = false
#### CONSTANTS FROM THE DEMO ENEMY ####

#ENEMY STATS
export (float) var strength = 50.0
var exp_worth = 150
var score_worth = 300
onready var hp = $Health
onready var hitbox = $Hitbox

export (PackedScene) var coin

enum States { IDLE, ROAM, FALL, RETURN, SPOT, FOLLOW, STAGGER, ATTACK, ATTACK_COOLDOWN, DIE, DEAD }
var state = null

var target
var has_target = false
var target_position = Vector2()

const MASS = 1.4
var velocity = Vector2()

var max_follow_speed = 200.0
var max_roam_speed = 80.0

const FOLLOW_RANGE = 300.0

var start_position = Vector2()
const ARRIVE_DISTANCE = 10.0
const SLOW_RADIUS = 150.0

var direction = -1

func _ready() -> void:
	initialize()
	target.connect('position_changed', self, '_on_target_position_changed')
	target.connect('died', self, '_on_target_died')
	connect("died", GAME, "_on_enemy_died", [exp_worth])
	connect("died", LEVEL, "_on_score_changed", [score_worth])

func initialize():
	target = get_node('/root/Game/Level').player
	if not target:
		print("No target, the monster won't follow or attack")
		_change_state(States.IDLE)
		return
	has_target = true
	if is_on_floor():
		_change_state(States.IDLE)
	else:
		_change_state(States.FALL)

func follow(target_position, max_speed):
	var desired_x = (target_position - position).normalized()
	desired_x = float(desired_x.x) * max_speed
	var desired_velocity = Vector2( desired_x, 0)
	var steering = (desired_velocity - Vector2(velocity.x, 0)) / MASS
	velocity += steering
	return position.distance_to(target_position)

func arrive_to(target_position, slow_radius, max_speed):
	var distance_to_target = position.distance_to(target_position)
	var desired_x = (target_position - position).normalized()
	desired_x = float(desired_x.x) * max_speed
	var desired_velocity = Vector2( desired_x, 0)
	if distance_to_target < slow_radius:
		desired_velocity *= (distance_to_target / slow_radius) * .75 + .25

	var steering = (desired_velocity - Vector2(velocity.x, 0)) / MASS
	velocity += steering
	return distance_to_target

func _change_state(new_state):
	state = new_state

func _physics_process(delta):
	onair_time += delta
	
	if is_on_floor():
		onair_time = 0
	
	on_floor = onair_time < MIN_ONAIR_TIME
	
	if not has_target:
		initialize()
#	var current_gravity = GRAVITY * delta
	velocity += delta * GRAVITY

	var current_state = state
	match current_state:
		States.IDLE:
			$anim.play("idle")
			move_and_slide(velocity, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
			var distance_to_target = position.distance_to(target_position)
			if distance_to_target < FOLLOW_RANGE:
				if not has_target:
					return
				_change_state(States.FOLLOW)
		States.FOLLOW:
			_update_look_direction(target_position)
			$anim.play("walk")
			var distance_to_target = follow(target_position, max_follow_speed)
			move_and_slide(velocity, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
#			if get_slide_count() > 0:
#				var collision_info = get_slide_collision(0)
#				if collision_info.collider.is_in_group("player"):
#					_change_state(States.ATTACK)
			if distance_to_target > FOLLOW_RANGE:
				_change_state(States.RETURN)
		States.RETURN:
			_update_look_direction(start_position)
			$anim.play("walk")
			if (start_position.x - position.x) < 0:
				$sprite.scale.x = -1
			else:
				$sprite.scale.x = 1
			var distance_to_target = arrive_to(start_position, SLOW_RADIUS, max_roam_speed)
			move_and_slide(velocity, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
			if distance_to_target < ARRIVE_DISTANCE:
				_change_state(States.IDLE)
			elif position.distance_to(target_position) < FOLLOW_RANGE:
				if not has_target:
					return
				_change_state(States.FOLLOW)
		States.FALL:
			$anim.play("idle")
			move_and_slide(velocity, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
			if self.is_on_floor():
				if not start_position:
					start_position = position
				_change_state(States.IDLE)
		States.DIE:
			$anim.play("explode")
			yield($anim, "animation_finished")
			_change_state(States.DEAD)
		States.DEAD:
			queue_free()

func drop_coin():
	var new_coin = coin.instance()
	new_coin.set("coin_value", 100)
	new_coin.set("position", position)
	get_parent().add_child(new_coin)

func _update_look_direction(target):
	if (target.x - position.x) < 0:
		$sprite.scale.x = -1
	else:
		$sprite.scale.x = 1

func _on_target_position_changed(new_position):
	target_position = new_position

func _on_target_died():
	_change_state(States.RETURN)
	has_target = false
	target_position = Vector2()


func _on_Hitbox_body_entered(body: PhysicsBody2D) -> void:
	if body.is_in_group("projectiles"):
		hp.take_damage(body.strength)
	if hp.health <= 0:
		hitbox.set_deferred("disabled", true)
		set_deferred("state", States.DIE)
		call_deferred("drop_coin")
		emit_signal("died")
	if hp.health < hp.max_health:
		$HookableHealthBar.set("visible", true)
