extends RigidBody2D

func _on_bullet_body_enter( body ):
	if body.has_method("hit_by_bullet"):
		$CollisionShape2D.disabled = true
		visible = false
		body.call("hit_by_bullet")

func _on_Timer_timeout():
	$anim.play("shutdown")
