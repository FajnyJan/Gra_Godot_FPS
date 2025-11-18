extends Node3D


@onready var target = $player
var EnemyScene = preload("res://enemy1.tscn")

func spawn_enemy(position: Vector3):
	var enemy = EnemyScene.instantiate()
	enemy.global_transform.origin = position
	add_child(enemy)
	enemy.add_to_group("enemy")

func _ready():
	spawn_enemy(Vector3(-10, 0, -10))
	spawn_enemy(Vector3(-10, 0, 0))
	spawn_enemy(Vector3(-10, 0, 10))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	get_tree().call_group("enemy", "target_position", target.global_transform.origin)
