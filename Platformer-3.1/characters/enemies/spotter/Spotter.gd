extends KinematicBody2D

#### CONSTANTS FROM THE DEMO ENEMY ####
const GRAVITY = 900.0
const FLOOR_NORMAL = Vector2(0, -1)
const WALK_SPEED = 140.0
#### CONSTANTS FROM THE DEMO ENEMY ####

#ENEMY STATS
export (float) var strength = 50.0 

enum States { IDLE, ROAM, FALL, RETURN, SPOT, FOLLOW, STAGGER, ATTACK, ATTACK_COOLDOWN, DIE, DEAD }
var state = null

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

func _ready():
	var target = get_node('/root/Game/Player')
	if not target:
		print("No target, the monster won't follow or attack")
		_change_state(States.IDLE)
		return
	target.connect('position_changed', self, '_on_target_position_changed')
	target.connect('died', self, '_on_target_died')
	has_target = true
	if is_on_floor():
		_change_state(States.IDLE)
	else:
		_change_state(States.FALL)
func follow(target_position, max_speed, gravity):
	var desired_x = (target_position - position).normalized()
	desired_x = float(desired_x.x) * max_speed
	var desired_velocity = Vector2( desired_x, gravity)
	var steering = (desired_velocity - velocity) / MASS
	velocity += steering
	return position.distance_to(target_position)

func arrive_to(target_position, slow_radius, max_speed, gravity):
	var distance_to_target = position.distance_to(target_position)
	var desired_x = (target_position - position).normalized()
	desired_x = float(desired_x.x) * max_speed
	var desired_velocity = Vector2( desired_x, gravity)
	if distance_to_target < slow_radius:
		desired_velocity *= (distance_to_target / slow_radius) * .75 + .25

	var steering = (desired_velocity - velocity) / MASS
	velocity += steering
	return distance_to_target

func _change_state(new_state):
	state = new_state

func _physics_process(delta):
	var current_gravity = GRAVITY * delta
	if (target_position.x - position.x) < 0:
		$sprite.scale.x = -1
	else:
		$sprite.scale.x = 1
	var current_state = state
	match current_state:
		States.IDLE:
			$anim.play("idle")
			velocity = Vector2(0, current_gravity)
			move_and_slide(velocity, FLOOR_NORMAL)
			var distance_to_target = position.distance_to(target_position)
			if distance_to_target < FOLLOW_RANGE:
				if not has_target:
					return
				_change_state(States.FOLLOW)
		States.FOLLOW:
			$anim.play("walk")
			var distance_to_target = follow(target_position, max_follow_speed, current_gravity)
			move_and_slide(velocity, FLOOR_NORMAL)
			if get_slide_count() > 0:
				var collision_info = get_slide_collision(0)
				if collision_info.collider.is_in_group("player"):
					_change_state(States.ATTACK)
				if distance_to_target > FOLLOW_RANGE:
					_change_state(States.RETURN)
		States.RETURN:
			$anim.play("walk")			
			if (start_position.x - position.x) < 0:
				$sprite.scale.x = -1
			else:
				$sprite.scale.x = 1
			var distance_to_target = arrive_to(start_position, SLOW_RADIUS, max_roam_speed, current_gravity)
			move_and_slide(velocity, FLOOR_NORMAL)
			print(distance_to_target < ARRIVE_DISTANCE)
			if distance_to_target < ARRIVE_DISTANCE:
				_change_state(States.IDLE)
			elif position.distance_to(target_position) < FOLLOW_RANGE:
				if not has_target:
					return
				_change_state(States.FOLLOW)
		States.FALL:
			$anim.play("idle")
			velocity = Vector2(0, current_gravity)
			move_and_slide(velocity, FLOOR_NORMAL)
			if self.is_on_floor():
				if not start_position:
					start_position = position
				_change_state(States.IDLE)


func _on_target_position_changed(new_position):
	target_position = new_position

func _on_target_died():
	_change_state(States.RETURN)
	has_target = false
	target_position = Vector2()

