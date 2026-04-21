extends Node3D

@export var range = 15
@export var fire_rate = 1.0
@export var damage: int = 3
var cooldown = 0

func _process(delta):
	cooldown -= delta
	var target = get_closest_enemy()
	if target and cooldown <= 0:
		var target_pos = target.global_transform.origin
		target_pos.y = global_transform.origin.y
		
		look_at(target_pos, Vector3.UP)
		shoot(target)
		cooldown = fire_rate

func get_closest_enemy():
	var closest = null
	var min_dist = range
	
	for enemy in get_tree().get_nodes_in_group("enemy"):
		var dist = global_transform.origin.distance_to(enemy.global_transform.origin)
		if dist < min_dist:
			min_dist = dist
			closest = enemy
	
	return closest

func shoot(enemy):
	var tower_pos = global_transform.origin
	var enemy_pos = enemy.global_transform.origin
	var direction = (enemy_pos - tower_pos).normalized()
	
	# raycast z wieży do wroga
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(tower_pos, enemy_pos)
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)
	
	if result:
		var collider = result.collider
		# jeśli trafiliśmy w wroga
		if collider == enemy:
			if collider.has_method("apply_damage"):
				collider.apply_damage(damage)
			print("Wieża trafiła: ", enemy.name)
