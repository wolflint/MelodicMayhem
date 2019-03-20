extends KinematicBody2D
# Physics setup
const GRAVITY_VEC = Vector2(0, 900)
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_SLIDE_STOP = 25.0
const MIN_ONAIR_TIME = 0.1
const WALK_SPEED = 250 # Pixels per second
const JUMP_SPEED = 480
const SIDING_CHANGE_SPEED = 10
const PROJECTILE_VELOCITY = 1000
const SHOOT_TIME_SHOW_WEAPON = 0.2

var linear_vel = Vector2()
var onair_time = 0
var on_floor = false
var shoot_time = 99999 # Time since last shot

# States
enum States {IDLE, WALK, JUMP, HURT}
var state = States.IDLE

# Sprite
onready var sprite = $Sprite

# Weapon variables
var weapon_cooldown = false

# Control variables
var move_left = Input.is_action_pressed("move_left")
var move_right = Input.is_action_pressed("move_right")
var jump = Input.is_action_just_pressed("jump")
var drop_down = Input.is_action_just_pressed("drop_down")
var shoot = Input.is_action_pressed("shoot")


func _ready():
	pass

func _physics_process(delta):
	# Increment counters
	onair_time += delta
	shoot_time += delta
	movement_control(delta)

func movement_control(delta):
	### MOVEMENT
	# Apply Gravity
	linear_vel += delta * GRAVITY_VEC
	# Move and Slide
	linear_vel = move_and_slide(linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
	# Detect Floor
	if is_on_floor():
		onair_time = 0
	
	on_floor = onair_time < MIN_ONAIR_TIME
	
	### CONTROLS
	# Jumping
	if on_floor and jump:
		linear_vel.y = -JUMP_SPEED
		state = States.JUMP
		change_animation()
	
	# Horizontal Movement
	var target_speed = 0
	if move_left:
		state = States.Walking
		sprite.scale.x = -1
		change_animation()
		target_speed = -1
	if move_right:
		state = States.Walking
		sprite.scale.x = 1
		change_animation()
		target_speed = 1
	
	target_speed *= WALK_SPEED
	linear_vel.x = lerp(linear_vel.x, target_speed, 0.1)
	
	# Drop down
	if drop_down:
		self.position = Vector2(self.position.x, self.position.y + 1)
	
	# Shooting WIP
	

func change_animation():
	match state:
		States.IDLE:
			$AnimationPlayer.play("idle")
		States.WALK:
			$AnimationPlayer.play("walk")
		States.JUMP:
			$AnimationPlayer.play("jump")
		States.HURT:
			$AnimationPlayer.play("hurt")

func _on_TextureButton_pressed():
	if state == States.IDLE:
		state = States.WALK
	elif state == States.WALK:
		state = States.JUMP
	elif state == States.JUMP:
		state = States.HURT
	else:
		state = States.IDLE
	change_animation()
