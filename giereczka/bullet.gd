extends CharacterBody3D

@export var speed: float = 60.0
@export var lifetime: float = 2.5

var shot_direction: Vector3 = Vector3.ZERO

func fire(direction: Vector3) -> void:
    shot_direction = direction.normalized()

func _physics_process(delta: float) -> void:
    if shot_direction == Vector3.ZERO:
        return

    var travel = shot_direction * speed * delta
    var collision = move_and_collide(travel)
    if collision:
        queue_free()
        return

    lifetime -= delta
    if lifetime <= 0.0:
        queue_free()
