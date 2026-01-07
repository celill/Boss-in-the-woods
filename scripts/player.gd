extends RigidBody3D

signal hp_changed(current, max_hp)
signal died

@export var speed = 40.0
@export var turn_speed = 2.0
@export var max_hp = 100.0

var hp = 100.0
var acceleration = 0.0
var steering = 0.0

# Weapon stats
var turret_cooldown = 0.3
var turret_timer = 0.0
var turret_range = 15.0

var saw_active = false
var saw_radius = 4.0
var saw_damage_timer = 0.0

@onready var visuals = $Visuals
@onready var saw_pivot = $Weapons/SawPivot
@onready var turret_pivot = $Weapons/TurretPivot
@onready var muzzle = $Weapons/TurretPivot/Muzzle

# References to managers (set by Main)
var game_manager = null

func _ready():
	hp = max_hp
	# Lock rotation to prevent flipping (Arcade feel)
	axis_lock_angular_x = true
	axis_lock_angular_z = true
	contact_monitor = true
	max_contacts_reported = 4
	linear_damp = 1.0
	angular_damp = 2.0

func _physics_process(delta):
	# Input
	acceleration = Input.get_axis("move_backward", "move_forward") * speed
	steering = Input.get_axis("move_right", "move_left") * turn_speed

	# Apply Forces in _integrate_forces or add_force here since we locked axes
	# For RigidBody, apply_central_force is relative to global, need to use basis

	var forward = -global_transform.basis.z
	if acceleration != 0:
		# Arcade physics: High force, rely on linear_damp for max speed cap
		apply_central_force(forward * acceleration * 2000.0)

	if steering != 0 and linear_velocity.length() > 1.0:
		# Only turn if moving
		var dir = 1 if linear_velocity.dot(forward) > 0 else -1
		apply_torque(Vector3.UP * steering * 20000.0 * dir)

	# Weapon Logic
	update_weapons(delta)

	# Check falling off map
	if global_position.y < -10:
		take_damage(9999)

func update_weapons(delta):
	# Saw Animation
	if saw_pivot.visible:
		saw_pivot.rotate_y(10 * delta)
		saw_damage_timer -= delta
		if saw_damage_timer <= 0:
			saw_damage_timer = 0.2
			check_saw_damage()

	# Turret Logic
	turret_timer -= delta
	if turret_timer <= 0:
		var target = find_nearest_enemy()
		if target:
			turret_pivot.look_at(target.global_position, Vector3.UP)
			shoot(target)
			turret_timer = turret_cooldown

func check_saw_damage():
	# Simple distance check for now
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if global_position.distance_to(enemy.global_position) < saw_radius:
			enemy.take_damage(10)

func find_nearest_enemy():
	var enemies = get_tree().get_nodes_in_group("enemies")
	var nearest = null
	var min_dist = turret_range

	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			nearest = enemy

	return nearest

func shoot(target):
	# In a real scenario we'd spawn a projectile, but for hitscan/instant feel:
	# Let's spawn a simple projectile for visual effect
	var projectile = load("res://scenes/projectile.tscn").instantiate()
	get_parent().add_child(projectile)
	projectile.global_transform = muzzle.global_transform
	# Projectile will handle moving and hitting

	# Play sound
	$ShootSound.play()

func take_damage(amount):
	hp -= amount
	hp_changed.emit(hp, max_hp)
	if hp <= 0:
		died.emit()
		# Add explosion effect here
		queue_free()

func upgrade_weapon(type):
	if type == "saw":
		saw_active = true
		saw_pivot.visible = true
	elif type == "turret":
		turret_cooldown *= 0.8
	elif type == "speed":
		speed *= 1.1
