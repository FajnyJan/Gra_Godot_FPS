extends Node3D


@onready var target = $player
var EnemyScene = preload("res://scenes/enemy1.tscn")
var Tower1Scene = preload("res://scenes/turrety/tower_1.tscn")
var Tower1PreviewScene = preload("res://scenes/turrety/turret_1-preview.tscn")
var Tower2Scene = preload("res://scenes/turrety/tower_2.tscn")
var Tower2PreviewScene = preload("res://scenes/turrety/turret_2-preview.tscn")

func spawn_enemy(position: Vector3):
	var enemy = EnemyScene.instantiate()
	add_child(enemy)
	enemy.global_transform = Transform3D(enemy.global_transform.basis, position)

func spawn_tower1(position: Vector3):
	var tower = Tower1Scene.instantiate()
	tower.global_transform.origin = position
	add_child(tower)

func show_tower1():
	var preview = Tower1PreviewScene.instantiate()
	add_child(preview)
	return preview

func spawn_tower2(position: Vector3):
	var tower = Tower2Scene.instantiate()
	tower.global_transform.origin = position
	add_child(tower)

func show_tower2():
	var preview = Tower2PreviewScene.instantiate()
	add_child(preview)
	return preview

func _ready():
	if Global.load_game:
		load_game()
	else:
		start_new_game()
   
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_tree().call_group("enemy", "target_position", target.global_transform.origin)
	if Input.is_action_just_pressed("get_to_menu"):
		toggle_pause()
		
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			toggle_pause() #pauzuje grę

func toggle_pause():
	var menu = $player/GameMenu/Panel
	var image = $player/GameMenu/Image

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



func _on_save_pressed():
	var packed_scene = PackedScene.new()
	packed_scene.pack($"świat")
	var data = {
		"player_position": {
			"x": $player.global_position.x,
			"y": $player.global_position.y,
			"z": $player.global_position.z
		}
	}

	var json_string = JSON.stringify(data, "\t")
	var file = FileAccess.open("res://saved/save.json", FileAccess.WRITE)
	ResourceSaver.save(packed_scene, "res://saved/SavedWorld.tscn")
	if file:
		file.store_string(json_string)
		file.close()
		print("saved")
	else:
		print("save error")

func load_game():
	if FileAccess.file_exists("res://saved/SavedWorld.tscn") and FileAccess.file_exists("res://saved/save.json"):
		var loaded_scene = load("res://saved/SavedWorld.tscn")
		var file = FileAccess.open("res://saved/save.json", FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		var json = JSON.new()
		var error = json.parse(content)
		if error != OK:
			print("json error")
			return
		var data = json.data
		var pos = Vector3(
			data["player_position"]["x"],
			data["player_position"]["y"],
			data["player_position"]["z"]
		)

		$player.global_position = pos
		if loaded_scene:
			$"świat".queue_free()
			var new_world = loaded_scene.instantiate()
			add_child(new_world)
			new_world.name = "Node3D"
			print("loaded")

func start_new_game():
	$player/GameMenu/Panel.visible = false
	$player/GameMenu/Image.visible = false
	spawn_enemy(Vector3(20, 0, -10))
	spawn_enemy(Vector3(20, 0, 0))
	spawn_enemy(Vector3(20, 0, -20))
