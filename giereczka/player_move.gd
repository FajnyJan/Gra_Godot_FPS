extends CharacterBody3D

@export var speed: float = 6.0
@export var jump_strength: float = 4.5
@export var gravity: float = 12.0
@export var health: int = 3
@export var bullet_scene: PackedScene
@export var shoot_offset: Vector3 = Vector3(0, 1.4, 1.2)

var is_dead: bool = false

func _ready() -> void:
	if not bullet_scene:
		var scene = load("res://giereczka/Bullet.tscn")
		if scene is PackedScene:
			bullet_scene = scene

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	var direction := Vector3.ZERO

	var input_x := Input.get_axis("ui_left", "ui_right")
	var input_z := Input.get_axis("ui_up", "ui_down")

	direction.x = input_x
	direction.z = input_z
	direction = global_transform.basis * direction
	direction.y = 0
	direction = direction.normalized()
	var horizontal_velocity := direction * speed
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z

	if not is_on_floor():
		velocity.y -= gravity * delta
	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		velocity.y = jump_strength

	if Input.is_action_just_pressed("shoot") or Input.is_action_just_pressed("ui_select"):
		_shoot()

	move_and_slide()

func _shoot() -> void:
	if not bullet_scene:
		return

	var bullet = bullet_scene.instantiate()
	var muzzle_pos = global_transform.origin + Vector3(0, shoot_offset.y, 0) - global_transform.basis.z * shoot_offset.z
	var direction = -global_transform.basis.z

	bullet.global_transform.origin = muzzle_pos
	bullet.global_transform.basis = Basis().looking_at(muzzle_pos + direction, Vector3.UP)
	bullet.fire(direction)

	get_tree().current_scene.add_child(bullet)

func take_damage(amount: int = 1) -> void:
	if is_dead:
		return

	health -= amount
	if health <= 0:
		health = 0
		_game_over()

func _game_over() -> void:
	is_dead = true
	var ui = CanvasLayer.new()
	var label = Label.new()
	label.text = "PRZEGRAŁEŚ"
	label.add_theme_font_size_override("font_size", 48)
	label.modulate = Color(1, 0.2, 0.2)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	label.horizontal_alignment = HorizontalAlignment.CENTER
	label.vertical_alignment = VerticalAlignment.CENTER
	label.rect_min_size = Vector2(600, 120)
	ui.add_child(label)
	get_tree().current_scene.add_child(ui)
