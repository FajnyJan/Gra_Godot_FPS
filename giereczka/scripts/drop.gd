extends Node3D

@onready var area_range = $Area3D
@onready var ammo = $ammunition
@onready var health = $health

var weights = [1, 1]

func _ready() -> void:
	area_range.body_entered.connect(_on_body_entered)
	
	ammo.visible = false
	health.visible = false

	spawn_random_pickup()

func _process(delta: float) -> void:
	var rot = rotation_degrees
	rot.y += 120.0 * delta
	rotation_degrees = rot


func spawn_random_pickup():
	var index = weighted_random(weights)

	if index == 0:
		ammo.visible = true
		health.visible = false
	else:
		ammo.visible = false
		health.visible = true


func _on_body_entered(body):
	if body.is_in_group("player"):

		if ammo.visible:
			body.pickup_ammo()
		elif health.visible:
			body.pickup_health()

		queue_free()


func weighted_random(weights: Array):
	var total = 0
	for w in weights:
		total += w

	var r = randf() * total
	var current = 0

	for i in range(weights.size()):
		current += weights[i]
		if r < current:
			return i

	return 0
