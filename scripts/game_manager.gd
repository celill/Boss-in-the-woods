extends Node3D

@export var enemy_scene: PackedScene
@export var spawn_rate = 2.0

var spawn_timer = 0.0
var spawn_radius = 40.0
var time_elapsed = 0.0

# Game State
var xp = 0
var level = 1
var xp_to_next = 20

@onready var player = $Player
@onready var hud = $UI/HUD

func _ready():
	if enemy_scene == null:
		enemy_scene = load("res://scenes/enemy.tscn")

	player.connect("hp_changed", _on_player_hp_changed)
	player.connect("died", _on_player_died)

	hud.update_level(level)
	hud.update_xp(xp, xp_to_next)
	hud.update_hp(player.hp, player.max_hp)

func _process(delta):
	time_elapsed += delta

	# Spawn Logic
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_enemy()
		spawn_timer = max(0.5, spawn_rate - (level * 0.1))

func spawn_enemy():
	if not is_instance_valid(player): return

	var angle = randf() * PI * 2
	var pos = player.global_position + Vector3(sin(angle), 0, cos(angle)) * spawn_radius

	var enemy = enemy_scene.instantiate()
	add_child(enemy)
	enemy.global_position = pos
	enemy.look_at(player.global_position, Vector3.UP)

func spawn_xp(pos, amount):
	# For now, just instant add
	xp += amount
	if xp >= xp_to_next:
		level_up()
	hud.update_xp(xp, xp_to_next)

func level_up():
	xp = 0
	level += 1
	xp_to_next = int(xp_to_next * 1.5)

	hud.update_level(level)
	hud.update_xp(xp, xp_to_next)
	$LevelUpSound.play()

	# Simple upgrade for now
	if randf() > 0.5:
		player.upgrade_weapon("turret")
		print("Turret Upgraded")
	else:
		player.upgrade_weapon("saw")
		print("Saw Upgraded")

func _on_player_hp_changed(current, max_h):
	hud.update_hp(current, max_h)

func _on_player_died():
	# Simple restart
	await get_tree().create_timer(3.0).timeout
	get_tree().reload_current_scene()
