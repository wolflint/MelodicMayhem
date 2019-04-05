extends Area2D

export (int) var max_spawn_amount = 10
export (PackedScene) var enemy
var player_in_spawn_area = false
var timer_running = false

func _process(delta):
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			player_in_spawn_area = true


func _on_SpawnTimer_timeout():
	var new_enemy = enemy.instance()
	if get_child_count() - 1 < max_spawn_amount:
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
