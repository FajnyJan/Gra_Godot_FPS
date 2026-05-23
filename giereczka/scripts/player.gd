extends CharacterBody3D
@onready var main = $".."


var speedmult = 5.0
const JUMP_VELOCITY = 4.5
var rotation_dir := 0
var rotation_speed := 2.0
@onready var camera = $Camera3D
var mouse_sensitivity = 0.002
var bullet_count = 30
var health = 100
@export var bullet_scene: PackedScene
@export var bullet_offset: float = 1.5
@export var bullet_speed: float = 80.0
@export var bullet_damage: int = 3
var placable_placing_last_pos = null
var build_mode = false
var placable_preview = null
var placable_rotation_y := 0.0
var placables := ["tower1", "tower2", "wall", "slope_wall"]
var placable_selected := 0

var is_dead = false

func _ready() -> void:
	add_to_group("player")
	add_to_group("destroyable")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func get_preview():
	match placables[placable_selected]:
		"tower1":
			return main.show_tower1()
		"tower2":
			return main.show_tower2()
		"wall":
			return main.show_wall()
		"slope_wall":
			return main.show_slope_wall()
	return null


func place_object(pos: Vector3):
	match placables[placable_selected]:
		"tower1":
			main.spawn_tower1(pos, placable_rotation_y)
		"tower2":
			main.spawn_tower2(pos, placable_rotation_y)
		"wall":
			main.spawn_wall(pos, placable_rotation_y)
		"slope_wall":
			main.spawn_slope_wall(pos, placable_rotation_y)


func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

	if Input.is_action_just_pressed("build_mode"):
		build_mode = !build_mode

		if placable_preview:
			placable_preview.queue_free()
			placable_preview = null

		if build_mode:
			placable_preview = get_preview()

	if Input.is_action_just_pressed("place_tower") and build_mode:
		if placable_placing_last_pos != null:
			place_object(placable_placing_last_pos)

	if Input.is_action_just_pressed("switch_placables"):
		placable_selected = (placable_selected + 1) % placables.size()

		if build_mode:
			if placable_preview:
				placable_preview.queue_free()
			placable_preview = get_preview()
	
	if Input.is_action_just_pressed("rotate_placable"):
		placable_rotation_y += PI / 2


var last_bullets = -1
var last_health = -1

func _process(delta):
	if bullet_count != last_bullets:
		$hud/bullets_l.text = str(bullet_count)
		last_bullets = bullet_count
	if health != last_health:
		$hud/health_l.text = str(health)
		last_health = health

	if build_mode:
		var space_state = get_world_3d().direct_space_state
		var origin = camera.global_transform.origin
		var end = origin - camera.global_transform.basis.z * 1000
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		query.exclude = [self]
		var result = space_state.intersect_ray(query)

		if result:
			var collider = result.collider
			if collider is GridMap:
				var normal = result.normal
				if normal.y > 0.7:
					var gridmap = collider
					var cell = gridmap.local_to_map(result.position)
					placable_placing_last_pos = gridmap.map_to_local(cell)

					if placable_preview:
						placable_preview.global_transform.origin = placable_placing_last_pos
						placable_preview.rotation.y = placable_rotation_y


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var speed = 5
	if Input.is_action_pressed("sprint"):
		speed = 15

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	rotation_dir = 0
	if Input.is_action_pressed("left_rotation"):
		rotation_dir = -1
	elif Input.is_action_pressed("right_rotation"):
		rotation_dir = 1
	rotate_y(rotation_dir * rotation_speed * delta)

	if Input.is_action_just_pressed("shoot"):
		if bullet_count > 0:
			bullet_count -= 1
			shoot()

	move_and_slide()


func shoot():
	var origin = camera.global_transform.origin
	var direction = -camera.global_transform.basis.z
	var spawn_position = origin + direction * bullet_offset

	if bullet_scene != null:
		_spawn_projectile(spawn_position, direction)
		return

	var space_state = get_world_3d().direct_space_state
	var end = origin + direction * 1000
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)

	if result and result.collider and result.collider.is_in_group("enemy"):
		result.collider.apply_damage(bullet_damage)


func _spawn_projectile(origin: Vector3, direction: Vector3) -> void:
	var bullet = bullet_scene.instantiate()
	if bullet is Node3D:
		bullet.global_transform = Transform3D(Basis(), origin)
		if bullet.has_method("set_direction"):
			bullet.set_direction(direction)
		if bullet.has_property("speed"):
			bullet.speed = bullet_speed
		if bullet.has_property("damage"):
			bullet.damage = bullet_damage
		get_tree().current_scene.add_child(bullet)


func continuee()->void:
	main._on_continue_pressed()

func optionss()->void:
	main._on_options_pressed()

func quitt()->void:
	main._on_quit_pressed()

func main_menuu()->void:
	main._on_main_menu_pressed()

func savee()->void:
	main._on_save_pressed()

func apply_damage_player(amount: int):
	health -= amount
	if health <= 0 and not is_dead:
		is_dead = true
		Global.do_win = 0
		get_tree().change_scene_to_file("res://scenes/endgame.tscn")

func pickup_item():
	bullet_count += 7
	health += 30
	if health > 100:
		health = 100
