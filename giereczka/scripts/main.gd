extends Node3D


@onready var target = $player
var EnemyScene = preload("res://scenes/enemy1.tscn")
var Tower1Scene = preload("res://scenes/turrety/tower_1.tscn")
var Tower1PreviewScene = preload("res://scenes/turrety/turret_1-preview.tscn")
var Tower2Scene = preload("res://scenes/turrety/tower_2.tscn")
var Tower2PreviewScene = preload("res://scenes/turrety/turret_2-preview.tscn")
@export var enemy_scene: PackedScene
var waves = {
	1:3,
	2:5,
	3:8,
	4:10
}
var current_wave = 1

func spawn_enemy(position: Vector3, health: int = 20):
	var enemy = EnemyScene.instantiate()
	add_child(enemy)
	enemy.health = health
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
	$player/GameMenu/Panel.visible = false
	$player/GameMenu/PoleBitwyMenu.visible = false
	$player/EndGame/Panel.visible = false
	$player/EndGame/win.visible = false
	$player/EndGame/lose.visible = false
	if Global.load_game:
		load_game()
	else:
		start_wave()
   
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_tree().call_group("enemy", "target_position", target.global_transform.origin)
	if Input.is_action_just_pressed("get_to_menu"):
		toggle_pause()
	if Global.how_many_enemy == 0:
		current_wave += 1
		if current_wave > waves.size():
			end_game(1)
		else:
			start_wave()
		
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			toggle_pause() #pauzuje grę

func toggle_pause():
	var menu = $player/GameMenu/Panel
	var image = $player/GameMenu/PoleBitwyMenu

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
		"player": save_player(),
		"enemies": save_group("enemy")
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
		if loaded_scene:
			$"świat".queue_free()
			var new_world = loaded_scene.instantiate()
			add_child(new_world)
			new_world.name = "Node3D"
		var json = JSON.new()
		var error = json.parse(content)
		if error != OK:
			print("json error")
			return
		var data = json.data
		var o = data["player"]["origin"]
		var b = data["player"]["basis"]
		var basis = Basis(
			Vector3(b[0][0], b[0][1], b[0][2]),
			Vector3(b[1][0], b[1][1], b[1][2]),
			Vector3(b[2][0], b[2][1], b[2][2])
		)
		var transform = Transform3D(basis, Vector3(o["x"], o["y"], o["z"]))
		$player.global_transform = transform
		load_enemies(data["enemies"])
		print("loaded")

func start_wave():
	randomize()
	var spawn_areas = get_tree().get_nodes_in_group("enemy_spawners")
	for area in spawn_areas:
		for i in range(waves[current_wave]):
			spawn_enemy(area.get_random_position())
			if Global.how_many_enemy == null:
				Global.how_many_enemy = 1
			else:
				Global.how_many_enemy+=1

func save_player():
	var t: Transform3D = $player.global_transform
	var data = {
			"origin": {
				"x": t.origin.x,
				"y": t.origin.y,
				"z": t.origin.z
			},
			"basis": [
				[t.basis.x.x, t.basis.x.y, t.basis.x.z],
				[t.basis.y.x, t.basis.y.y, t.basis.y.z],
				[t.basis.z.x, t.basis.z.y, t.basis.z.z]
			]
		}
	return data

func save_group(group_name: String):
	var arr = []

	for node in get_tree().get_nodes_in_group(group_name):
		if node.has_method("save_state"):
			arr.append(node.save_state())

	return arr

func dict_to_transform(d: Dictionary) -> Transform3D:
	var o = d["origin"]
	var b = d["basis"]

	var basis = Basis(
		Vector3(b[0][0], b[0][1], b[0][2]),
		Vector3(b[1][0], b[1][1], b[1][2]),
		Vector3(b[2][0], b[2][1], b[2][2])
	)

	return Transform3D(
		basis,
		Vector3(o["x"], o["y"], o["z"])
	)

func load_enemies(data: Array):
	for enemy_data in data:

		var transform_dict = enemy_data["transform"]
		var transform = dict_to_transform(transform_dict)
		var pos = transform.origin
		var hp = enemy_data.get("health", 20)

		spawn_enemy(pos, hp)

func end_game(do_win:int):
	var menu = $player/EndGame/Panel
	menu.visible = !menu.visible
	get_tree().paused = menu.visible
	
	if menu.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if do_win:
		var image = $player/EndGame/win
		image.visible = menu.visible
	else:
		var image = $player/EndGame/lose
		image.visible = menu.visible
