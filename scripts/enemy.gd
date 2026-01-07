extends RigidBody3D

@export var speed = 15.0
@export var hp = 30.0
@export var damage = 10.0

var player_ref = null

func _ready():
	contact_monitor = true
	max_contacts_reported = 2
	axis_lock_angular_x = true
	axis_lock_angular_z = true

	player_ref = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if is_instance_valid(player_ref):
		var dir = (player_ref.global_position - global_position).normalized()
		# Look at player (but keep Y up)
		look_at(Vector3(player_ref.global_position.x, global_position.y, player_ref.global_position.z), Vector3.UP)

		# Move towards player
		apply_central_force(dir * speed * 100.0)

	# Check collisions
	var bodies = get_colliding_bodies()
	for body in bodies:
		if body.is_in_group("player"):
			body.take_damage(damage * delta) # Constant damage while touching
			# Push back slightly
			apply_central_impulse(-global_transform.basis.z * 5.0)

func take_damage(amount):
	hp -= amount
	# Visual flash
	$Visuals.scale = Vector3(1.2, 1.2, 1.2)
	var tween = create_tween()
	tween.tween_property($Visuals, "scale", Vector3.ONE, 0.1)

	if hp <= 0:
		die()

func die():
	# Drop XP or loot
	if get_parent().has_method("spawn_xp"):
		get_parent().spawn_xp(global_position, 10)

	$ExplosionSound.play()
	# Hide and queue_free after sound
	visible = false
	collision_layer = 0
	collision_mask = 0
	await $ExplosionSound.finished
	queue_free()
