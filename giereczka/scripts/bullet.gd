extends Area3D

var speed = 1.0
var direction = Vector3.ZERO
var lifetime = 10.0
var damage = 25

func _ready():
	body_entered.connect(_on_body_entered)

	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	global_position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		if body.has_method("apply_damage"):
			body.apply_damage(damage)

	queue_free()
