extends CharacterBody3D

@export var speed: float = 6.0
@export var jump_strength: float = 4.5
@export var gravity: float = 12.0

func _physics_process(delta: float) -> void:
	var direction := Vector3.ZERO

	# wejście w osiach
	var input_x := Input.get_axis("ui_left", "ui_right")
	var input_z := Input.get_axis("ui_up", "ui_down")

	# tworzymy kierunek w przestrzeni
	direction.x = input_x
	direction.z = input_z

	# obracamy zgodnie z orientacją gracza
	direction = global_transform.basis * direction
	direction.y = 0
	direction = direction.normalized()

	# ruch poziomy
	var horizontal_velocity := direction * speed
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z

	# grawitacja
	if not is_on_floor():
		velocity.y -= gravity * delta

	# skok
	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		velocity.y = jump_strength

	# ruch finalny
	move_and_slide()
