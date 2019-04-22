extends RigidBody2D

var strength = 1

func _ready() -> void:
	print(strength)


func _on_Timer_timeout():
	$anim.play("shutdown")
