extends Node3D

var speed = 60.0
var damage = 25.0
var life = 2.0

func _process(delta):
	# Move forward locally
	translate(Vector3.FORWARD * speed * delta)
	life -= delta
	if life <= 0:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
	elif body.is_in_group("world"):
		queue_free()
