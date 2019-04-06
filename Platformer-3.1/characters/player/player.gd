extends KinematicBody2D

signal experience_gained(growth_data, player)
signal health_changed(health, max_health)
signal gained_max_health()
signal music_level_changed(current_music, max_music)

# FOR SPOTTER
signal position_changed
signal died

# Character stats
export (int) var max_hp = 12
export (int) var strength = 8
export (int) var max_music = 50
var current_music

# Experience and leveling system
export (int) var level = 1

var experience = 0
var experience_total = 0
var experience_required = get_required_experience(level + 1)

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

onready var sprite = $sprite

var cooldown = false

func _ready():
	state = States.IDLE
	current_music = max_music
	connect("gained_max_health", $Health, "_on_Player_gained_max_health")

func _input(event):
	# Jumping
	if jump_count < MAX_JUMP_COUNT and event.is_action_pressed("jump"):
		linear_vel.y = -JUMP_SPEED
		$sound_jump.play()
		jump_count += 1
	if event.is_action_pressed("test_button"):
		$Health.take_damage(10)

func _physics_process(delta):
	_check_collisions()
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
	emit_signal('position_changed', global_position)

func _horizontal_movement():
	var target_speed = 0
	if Input.is_action_pressed("move_left"):
		target_speed += -1
	if Input.is_action_pressed("move_right"):
		target_speed +=  1

	target_speed *= WALK_SPEED
	linear_vel.x = lerp(linear_vel.x, target_speed, 0.1)

func _shoot():
	# Shooting
	if Input.is_action_pressed("shoot"):
		$MusicRegen.stop()
		if current_music != 0:
			if current_weapon and !cooldown:
				current_music -= 1
				emit_signal("music_level_changed", current_music, max_music)
				var bullet = preload("note.tscn").instance()
				bullet.set("strength", strength)
				bullet.position = $sprite/bullet_shoot.global_position #use node for shoot position
				bullet.linear_velocity = Vector2(sprite.scale.x * BULLET_VELOCITY, 0)
				bullet.add_collision_exception_with(self) # don't want player to collide with bullet
				get_parent().add_child(bullet) #don't want bullet to move with me, so add it as child of parent
				$Cooldown.start()
				cooldown = true
				$sound_shoot.play()
				shoot_time = 0
	elif not Input.is_action_just_pressed("shoot"):
		if $MusicRegen.is_stopped():
			$MusicRegen.start()

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

func _check_collisions():
	for body in $Hitbox.get_overlapping_bodies():
		$Health.take_damage(body.strength)
		_stagger()

func _stagger():
	$Hitbox/CollisionShape2D.disabled = true
	# DO STAGGER HERE
	$Stagger.start()
	$anim.play("stagger")
	linear_vel.y = float(-JUMP_SPEED * 0.75) 
	yield($Stagger, "timeout")
	$Hitbox/CollisionShape2D.disabled = false
	

#func take_damage(damager, amount):
#	if self.is_a_parent_of(damager):
#		return
#	knockback_direction = (damager.global_position - global_position).normalized()
#	$Health.take_damage(amount)

func get_required_experience(amount):
	return round(pow(level, 1.8) + level * 4)

func gain_experience(amount):
	experience_total += amount
	experience += amount
	var growth_data = []
	while experience >= experience_required:
		experience -= experience_required
		growth_data.append([experience_required, experience_required])
		level_up()
	growth_data.append([experience, get_required_experience(level + 1)])
	emit_signal("experience_gained", growth_data, self)

func level_up():
	level += 1
	experience_required = get_required_experience(level + 1)
	randomize()
	var stats = ['max_hp', 'strength', 'max_music']
	var random_stat = stats[randi() % stats.size()]
	match random_stat:
		'max_hp':
			emit_signal("gained_max_health")
			emit_signal("health_changed", $Health.health, $Health.max_health)
		'strength', 'max_music':
			set(random_stat, get(random_stat) + randi() % 4)
		'max_music':
			emit_signal("music_level_changed", current_music, max_music)


func _on_Health_health_changed(new_health):
	if new_health <= 0:
		emit_signal('died')
	emit_signal("health_changed", new_health, $Health.max_health)


func _on_Cooldown_timeout():
	cooldown = false


func _on_MusicRegen_timeout():
	if current_music == max_music:
		return
	current_music = min(current_music + 1, max_music)
	emit_signal("music_level_changed", current_music, max_music)
