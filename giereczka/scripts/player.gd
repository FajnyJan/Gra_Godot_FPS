extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var rotation_dir := 0
var rotation_speed := 2.0
@onready var camera = $Camera3D
var mouse_sensitivity = 0.002

func _ready() -> void:
	add_to_group("player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	rotation_dir = 0
	if Input.is_action_pressed("left_rotation"):
		rotation_dir = -1
	elif Input.is_action_pressed("right_rotation"):
		rotation_dir = 1
	rotate_y(rotation_dir * rotation_speed * delta)
	
	if Input.is_action_just_pressed("shoot"):
		shoot()
	

	move_and_slide()

func shoot():
	var space_state = get_world_3d().direct_space_state
	var origin = camera.global_transform.origin
	var end = origin - camera.global_transform.basis.z * 1000
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	if result:
		if result.collider.is_in_group("enemy"):
			result.collider.apply_damage(4)
