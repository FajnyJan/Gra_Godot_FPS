extends Node3D

@export var range = 15
@export var fire_rate = 1.0
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
	print("cel: ", enemy.name)#strzelanko
