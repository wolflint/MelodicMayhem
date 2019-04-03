extends RigidBody2D

export (int) var strength = 25
#func _on_bullet_body_enter(body):
#	if body.has_method("hit_by_bullet"):
#		body.call("hit_by_bullet")

func _on_Timer_timeout():
	$anim.play("shutdown")
