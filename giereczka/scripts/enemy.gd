
extends CharacterBody3D

@onready var nav = $NavigationAgent3D
@onready var animations = $Skeleton_Mage/Rig_Medium/Skeleton3D/AnimationPlayer
@onready var attack_range = $AttackRange
var DropScene = preload("res://scenes/drop.tscn")

var health: int

var speed = 3.5
var gravity = 9.8
var jump_velocity = 3.0
var target = null
var is_dead = false
var destroy_in_range = false
var damage = 10
var attack_cooldown = 0.0
var attack_rate = 1.0
var attack_target = null
var detection_range = 15.0

func _ready():
	add_to_group("enemy")
	animations.play("Running_A")

	attack_range.body_entered.connect(_on_attack_range_body_entered)
	attack_range.body_exited.connect(_on_attack_range_body_exited)

func _physics_process(delta):
	attack_cooldown -= delta
	$Label3D.text = str(health)
	
	if is_dead:
		var rot = rotation_degrees
		
		if rot.x < 90:
			rot.x += 120.0 * delta
			rotation_degrees = rot
		else:
			rotation_degrees.x = 90
			queue_free()
			return
	else:
		target = get_priority_target()
		
		if not is_on_floor():
			velocity.y -= gravity * delta
		elif is_on_wall(): 
			velocity.y = jump_velocity
		if not $RayCast3D.is_colliding():
			velocity.y = jump_velocity
		if destroy_in_range:
			velocity.x = 0
			velocity.z = 0
		else:
			if target != null:
				nav.target_position = target.global_position

			var next_location = nav.get_next_path_position()
			var direction = (next_location - global_position).normalized()
			var new_velocity = direction * speed

			velocity.x = new_velocity.x
			velocity.z = new_velocity.z

		move_and_slide()

		if target != null:
			var target_pos = target.global_position
			target_pos.y = global_position.y
			look_at(target_pos, Vector3.UP)
			rotate_y(deg_to_rad(90))
		if destroy_in_range and attack_target != null:
			if attack_cooldown <= 0.0:
				if attack_target.has_method("apply_damage_player"):
					attack_target.apply_damage_player(damage)
				attack_cooldown = attack_rate

func target_position(pos: Vector3):
	nav.target_position = pos

func apply_damage(amount: int):
	health -= amount
	if health <= 0 and not is_dead:
		Global.how_many_enemy -=1
		remove_from_group("enemy")
		is_dead = true
		drop_drop()

func get_closest_target():
	var closest = null
	var min_dist = INF

	for t in get_tree().get_nodes_in_group("player"):
		var dist = global_position.distance_to(t.global_position)

		if closest == null or dist < min_dist:
			min_dist = dist
			closest = t

	return closest

func _on_attack_range_body_entered(body):
	if body.is_in_group("destroyable"):
		destroy_in_range = true
		animations.play("Attack")
		attack_target = body

func _on_attack_range_body_exited(body):
	if body.is_in_group("destroyable"):
		destroy_in_range = false
		animations.play("Running_A")
		attack_target = null

func save_state():
	var t: Transform3D = global_transform

	return {
		"type": "enemy1",
		"health": health,
		"transform": {
			"origin": {
				"x": t.origin.x,
				"y": t.origin.y,
				"z": t.origin.z
			},
			"basis": [
				[t.basis.x.x, t.basis.x.y, t.basis.x.z],
				[t.basis.y.x, t.basis.y.y, t.basis.y.z],
				[t.basis.z.x, t.basis.z.y, t.basis.z.z]
			]
		}
	}

func drop_drop():
	var drop = DropScene.instantiate()
	$"..".add_child(drop)
	drop.global_transform = global_transform

func get_priority_target():
	var closest_player = null
	var closest_chest = null
	var player_dist = INF
	var chest_dist = INF
	for p in get_tree().get_nodes_in_group("player"):
		var dist = global_position.distance_to(p.global_position)
		if dist < player_dist:
			player_dist = dist
			closest_player = p
	for c in get_tree().get_nodes_in_group("chest"):
		var dist = global_position.distance_to(c.global_position)
		if dist < chest_dist:
			chest_dist = dist
			closest_chest = c
	if closest_player != null and player_dist <= detection_range:
		if closest_chest != null and chest_dist < player_dist:
			return closest_chest
		return closest_player
	if closest_chest != null:
		return closest_chest
	return closest_player
