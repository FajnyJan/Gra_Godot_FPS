extends Area3D

var speed = 33.33
var direction = Vector3.FORWARD
var lifetime = 2  # czas lotu w sekundach

func _ready():
	print("Bullet spawned at: ", global_transform.origin)
	# Dla Area3D, poruszamy ręcznie
	set_physics_process(true)
	monitoring = true
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	global_transform.origin += direction * speed * delta

func _on_body_entered(body):
	print("Bullet hit: ", body.name)
	if body.is_in_group("enemy"):
		body.apply_damage(25)
	queue_free()
