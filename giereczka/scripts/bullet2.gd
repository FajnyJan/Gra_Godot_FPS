extends CharacterBody3D

var speed = 10.0
var direction = Vector3.ZERO
var damage = 3
var lifetime = 10.0

func _ready():
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	if direction != Vector3.ZERO:
		look_at(global_position + direction)
		rotate_y(deg_to_rad(180))
	var collision = move_and_collide(direction * speed * delta)
	if collision:
		var body = collision.get_collider()
		if body.is_in_group("enemy"):
			if body.has_method("apply_damage"):
				body.apply_damage(damage)
			queue_free()
