
extends Node3D

@export var attack_range = 15
@export var fire_rate = 1.0
@export var damage: int = 3
var cooldown = 0.0

@onready var gun = $turret1/stojak

var BulletScene = preload("res://scenes/Bullet.tscn")

func _process(delta):
	cooldown -= delta
	
	if gun == null:
		return
		
	var target = get_closest_enemy()
	if target and cooldown <= 0:
		var target_pos = target.global_position
		
		# Wyrównuje wysokość celu do wysokości działa
		target_pos.y = gun.global_position.y
		
		# Obraca stojak
		gun.look_at(target_pos, Vector3.UP)
		gun.rotate_object_local(Vector3.RIGHT, deg_to_rad(90))
		gun.rotate_object_local(Vector3.FORWARD, deg_to_rad(180))
		
		shoot(target)
		cooldown = fire_rate

func get_closest_enemy():
	var closest = null
	var min_dist = attack_range
	
	for enemy in get_tree().get_nodes_in_group("enemy"):
		var dist = global_position.distance_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = enemy
	
	return closest

func shoot(enemy):
	if enemy == null:
		return

	var bullet = BulletScene.instantiate()

	# dodanie pocisku do sceny
	get_tree().current_scene.add_child(bullet)

	# miejsce spawnu pocisku
	bullet.global_position = gun.global_position

	# kierunek lotu
	bullet.direction = (
		enemy.global_position - gun.global_position
	).normalized()

	print("Wystrzelono pocisk")
