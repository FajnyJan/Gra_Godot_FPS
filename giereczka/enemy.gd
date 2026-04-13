extends CharacterBody3D

@onready var nav = $NavigationAgent3D

var speed = 3.5
var gravity = 9.8
var health = 20.0
var target = null

func _ready():
	add_to_group("enemy")
	$"Armature/Skeleton3D/7_m19beruto_tga_0_1_16_16/AnimationPlayer".play("chodzenie")

func _physics_process(delta):
	$Label3D.text = str(health)

	if not is_on_floor():
		velocity.y -= gravity * delta

	target = get_closest_target()

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
	if health <= 0:
		queue_free()

func get_closest_target():
	var closest = null
	var min_dist = INF

	for t in get_tree().get_nodes_in_group("player"):
		var dist = global_position.distance_to(t.global_position)

		if closest == null or dist < min_dist:
			min_dist = dist
			closest = t

	return closest
