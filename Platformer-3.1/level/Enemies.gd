extends Position2D

export (int) var spawn_amount = 10
export (PackedScene) var enemy

func _input(event):
	if event.is_action_pressed("spawn"):
		for i in spawn_amount:
			var new_enemy = enemy.instance()
			new_enemy.position = position
			add_child(new_enemy)
			