extends CharacterBody3D

var speed = 30.0
var direction = Vector3.ZERO
var damage = 5
var lifetime = 5.0

func _ready():
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	var collision = move_and_collide(direction * speed * delta)

	if collision:
		var hit_body = collision.get_collider()

		if hit_body.is_in_group("enemy"):
			if hit_body.has_method("apply_damage"):
				hit_body.apply_damage(damage)

		queue_free()
