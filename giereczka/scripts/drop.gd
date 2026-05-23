extends Node3D

@onready var area_range = $Area3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_range.body_entered.connect(_on_body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var rot = rotation_degrees
	rot.y += 120.0 * delta
	rotation_degrees = rot

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.pickup_item()
		queue_free()
