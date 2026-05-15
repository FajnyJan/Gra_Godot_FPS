extends Area3D

@export var enemy_count = 3

func _ready() -> void:
	add_to_group("enemy_spawners")

func get_random_position() -> Vector3:
	var shape = $CollisionShape3D.shape as BoxShape3D
	var size = shape.size
	
	return global_position + Vector3(
		randf_range(-size.x / 2.0, size.x / 2.0),
		0,
		randf_range(-size.z / 2.0, size.z / 2.0)
	)
