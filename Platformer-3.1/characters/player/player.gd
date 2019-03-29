extends KinematicBody2D

# States
enum States {
	IDLE,
	MOVE,
	JUMP,
}
var state

# Gameplay constants
const GRAVITY_VEC = Vector2(0, 1000)
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_SLIDE_STOP = 25.0
const MIN_ONAIR_TIME = 0.1
const WALK_SPEED = 250 # pixels/sec
const JUMP_SPEED = 480
const SIDING_CHANGE_SPEED = 10
const BULLET_VELOCITY = 1000
const SHOOT_TIME_SHOW_WEAPON = 0.2
const MAX_JUMP_COUNT = 2

# Gameplay variables
var linear_vel = Vector2()
var onair_time = 0 #
var on_floor = false
var shoot_time=99999 #time since last shot
var jump_count = 0

var knockback_direction = Vector2()
export(float) var knockback = 10
const STAGGER_DURATION = 0.4

onready var current_weapon = $weapon.weapon_type

var anim=""

#cache the sprite here for fast access (we will set scale to flip it often)
onready var sprite = $sprite

func _ready():
	state = States.IDLE

func _input(event):
	# Jumping
	if jump_count < MAX_JUMP_COUNT and Input.is_action_just_pressed("jump"):
		linear_vel.y = -JUMP_SPEED
		$sound_jump.play()
		jump_count += 1

func _physics_process(delta):
	#increment counters

	onair_time += delta
	shoot_time += delta

	### MOVEMENT ###

	# Apply Gravity
	linear_vel += delta * GRAVITY_VEC
	# Move and Slide
	linear_vel = move_and_slide(linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
	# Detect Floor
	if is_on_floor():
		onair_time = 0
		jump_count = 0

	on_floor = onair_time < MIN_ONAIR_TIME

	### CONTROL ###
	_horizontal_movement()

	# Drop down
	if Input.is_action_pressed("drop_down"):
		self.global_position += Vector2(0,1)
	
	_shoot()

	_animate_sprite()

func _horizontal_movement():
#	var target_speed = 0
#	target_speed = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
#
#	target_speed *= WALK_SPEED
#	linear_vel.x = lerp(linear_vel.x, target_speed, 0.1)
# Horizontal Movement
	var target_speed = 0
	if Input.is_action_pressed("move_left"):
		target_speed += -1
	if Input.is_action_pressed("move_right"):
		target_speed +=  1

	target_speed *= WALK_SPEED
	linear_vel.x = lerp(linear_vel.x, target_speed, 0.1)

func _shoot():
	# Shooting
	if Input.is_action_just_pressed("shoot"):
		if current_weapon:
			var bullet = preload("note.tscn").instance()
			bullet.position = $sprite/bullet_shoot.global_position #use node for shoot position
			bullet.linear_velocity = Vector2(sprite.scale.x * BULLET_VELOCITY, 0)
			bullet.add_collision_exception_with(self) # don't want player to collide with bullet
			get_parent().add_child(bullet) #don't want bullet to move with me, so add it as child of parent
			$sound_shoot.play()
			shoot_time = 0

func _animate_sprite(new_anim = "idle"):
	### ANIMATION ###
	if on_floor:
		if linear_vel.x < -SIDING_CHANGE_SPEED:
			sprite.scale.x = -1
			new_anim = "run"

		if linear_vel.x > SIDING_CHANGE_SPEED:
			sprite.scale.x = 1
			new_anim = "run"
	else:
		# We want the character to immediately change facing side when the player
		# tries to change direction, during air control.
		# This allows for example the player to shoot quickly left then right.
		if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
			sprite.scale.x = -1
		if Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
			sprite.scale.x = 1
		if Input.is_action_just_pressed("drop_down"):
			new_anim = "crouch"
		if linear_vel.y < 0:
			new_anim = "jumping"
		else:
			new_anim = "falling"

	if shoot_time < SHOOT_TIME_SHOW_WEAPON:
		new_anim += "_weapon"

	if new_anim != anim:
		anim = new_anim
		$anim.play(anim)

func _stagger():
	$Tween.interpolate_property(self, 'position', position, position + knockback * -knockback_direction, STAGGER_DURATION, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.start()

func take_damage(damager, amount):
	if self.is_a_parent_of(damager):
		return
	knockback_direction = (damager.global_position - global_position).normalized()
	$Health.take_damage(amount)

func _on_Health_health_changed(new_health):
#	_change_state(IDLE)
	print('%s new health is %s' % [self.name, new_health])
#	if new_health == 0:
#		queue_free()