extends Node3D


@onready var target = $player
var EnemyScene = preload("res://scenes/enemy1.tscn")
var Tower1Scene = preload("res://scenes/tower_1.tscn")

func spawn_enemy(position: Vector3):
	var enemy = EnemyScene.instantiate()
	enemy.global_transform.origin = position
	add_child(enemy)

func spawn_tower1(position: Vector3):
	var tower1 = Tower1Scene.instantiate()
	tower1.global_transform.origin = position
	add_child(tower1)

func _ready():
	$GameMenu/Panel.visible = false
	$GameMenu/Image.visible = false
	spawn_enemy(Vector3(-10, 0, -10))
	spawn_enemy(Vector3(-10, 0, 0))
	spawn_enemy(Vector3(-10, 0, 10))
   

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_tree().call_group("enemy", "target_position", target.global_transform.origin)
	if Input.is_action_just_pressed("go_to_menu"):
		toggle_pause()
		
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			toggle_pause() #pauzuje grę

func toggle_pause():
	var menu = $GameMenu/Panel
	var image = $GameMenu/Image

	menu.visible = !menu.visible
	image.visible = menu.visible
	
	get_tree().paused = menu.visible
		#pokazuje elementy menu
	
	if menu.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		#blokuje ruch kamery aby kursor był widoczny

func _on_continue_pressed() -> void:
	toggle_pause()


func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menu.tscn")
