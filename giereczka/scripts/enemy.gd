
extends CharacterBody3D

@onready var nav = $NavigationAgent3D
@onready var animations = $Skeleton_Mage/Rig_Medium/Skeleton3D/AnimationPlayer
@onready var attack_range = $AttackRange

var health: int

var speed = 3.5
var gravity = 9.8
var jump_velocity = 3.0
var target = null
var is_dead = false
var destroy_in_range = false

func _ready():
	add_to_group("enemy")
	animations.play("Running_A")

	attack_range.body_entered.connect(_on_attack_range_body_entered)
	attack_range.body_exited.connect(_on_attack_range_body_exited)

func _physics_process(delta):
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
		target = get_closest_target()
		
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

func target_position(pos: Vector3):
	nav.target_position = pos

func apply_damage(amount: int):
	health -= amount
	if health <= 0 and not is_dead:
		remove_from_group("enemy")
		is_dead = true

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

func _on_attack_range_body_exited(body):
	if body.is_in_group("destroyable"):
		destroy_in_range = false
		animations.play("Running_A")

func save_state():
	return {
		"type": "enemy1",
		"transform": global_transform,
		"health": health
	}
