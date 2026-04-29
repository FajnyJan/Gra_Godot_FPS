
extends Node3D

@export var attack_range = 15
@export var fire_rate = 1.0
@export var damage: int = 3
var cooldown = 0.0

@onready var gun = $turret1/stojak

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
	var tower_pos = gun.global_position 
	var enemy_pos = enemy.global_position
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(tower_pos, enemy_pos)
	query.exclude = [self] 
	
	var result = space_state.intersect_ray(query)
	
	if result:
		var collider = result.collider
		if collider == enemy:
			if collider.has_method("apply_damage"):
				collider.apply_damage(damage)
			print("Wieża trafiła: ", enemy.name)
