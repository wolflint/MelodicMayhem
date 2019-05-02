extends Area2D

export (int) var max_spawn_amount = 10
export (PackedScene) var enemy
var player_in_spawn_area = false
var timer_running = false
onready var col_shape = get_node("CollisionShape2D")

#func _ready():
#	connect("body_entered", self, "_on_EnemySpawner_body_entered")
#	connect("body_exited", self, "_on_EnemySpawner_body_exited")

func _process(delta):
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			player_in_spawn_area = true

func randomise_spawn_position():
	var center_pos = col_shape.position + position
	var size = col_shape.shape.extents
	var rand_pos = Vector2()
	randomize()
	rand_pos.x = (randi() % int(size.x)) - (size.x / 2)
	rand_pos.y = (randi() % int(size.y)) - (size.y / 2)
	return rand_pos

func _on_SpawnTimer_timeout():
	var new_enemy = enemy.instance()
	if get_child_count() - 1 < max_spawn_amount:
		new_enemy.position = randomise_spawn_position()
		add_child(new_enemy)
	if player_in_spawn_area:
		$SpawnTimer.start()
	if not player_in_spawn_area:
		$SpawnTimer.stop()


func _on_EnemySpawner_body_entered(body):
	if body.is_in_group("player"):
		player_in_spawn_area = true
		$SpawnTimer.start()


func _on_EnemySpawner_body_exited(body):
	if body.is_in_group("player"):
		player_in_spawn_area = false
