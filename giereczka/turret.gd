extends Node3D

@export var bullet_scene: PackedScene
@export var fire_interval: float = 1.5
@export var muzzle_offset: Vector3 = Vector3(0, 1.2, 0)
@export var target_path: NodePath

var _timer: float = 0.0

func _ready() -> void:
    _timer = fire_interval

func _physics_process(delta: float) -> void:
    var target = get_node_or_null(Node3D, target_path)
    if not target:
        return

    _timer -= delta
    look_at(target.global_transform.origin, Vector3.UP)

    if _timer <= 0.0:
        _timer = fire_interval
        _shoot_at(target.global_transform.origin)

func _shoot_at(target_position: Vector3) -> void:
    if not bullet_scene:
        return

    var bullet = bullet_scene.instantiate()
    var origin = global_transform.origin + muzzle_offset
    var direction = (target_position - origin).normalized()

    bullet.global_transform.origin = origin
    bullet.global_transform.basis = Basis().looking_at(origin + direction, Vector3.UP)
    bullet.fire(direction)
    get_tree().current_scene.add_child(bullet)
