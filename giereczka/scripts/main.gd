extends Node3D


@onready var target = $player
var enemy_scenes = [
	preload("res://scenes/enemy1.tscn"),
	preload("res://scenes/enemy2.tscn")
]
var Tower1Scene = preload("res://scenes/placables/tower_1.tscn")
var Tower1PreviewScene = preload("res://scenes/placables/turret_1-preview.tscn")
var Tower2Scene = preload("res://scenes/placables/tower_2.tscn")
var Tower2PreviewScene = preload("res://scenes/placables/turret_2-preview.tscn")
var WallScene = preload("res://scenes/placables/wall.tscn")
var WallPreviewScene = preload("res://scenes/placables/wall-preview.tscn")
var SlopeWallScene = preload("res://scenes/placables/slope_wall.tscn")
var SlopeWallPreviewScene = preload("res://scenes/placables/slope_wall-preview.tscn")
@export var enemy_scene: PackedScene
var waves = {
	1:3,
	2:5,
	3:8,
	4:10
}
var current_wave = 1
var spawn_weights = [1, 1]

func spawn_enemy(position: Vector3, health: int = 20):
	var selected_scene = get_random_enemy_scene()
	var enemy = selected_scene.instantiate()
	add_child(enemy)
	enemy.health = health
	enemy.global_transform = Transform3D(enemy.global_transform.basis, position)

func spawn_tower1(position: Vector3, rot_y: float = 0.0):
	var object = Tower1Scene.instantiate()
	object.global_transform.origin = position
	object.rotation.y = rot_y
	object.add_to_group("buildable")
	object.set_meta("build_type", "tower1")
	add_child(object)

func show_tower1():
	var preview = Tower1PreviewScene.instantiate()
	add_child(preview)
	return preview

func spawn_tower2(position: Vector3, rot_y: float = 0.0):
	var object = Tower2Scene.instantiate()
	object.global_transform.origin = position
	object.rotation.y = rot_y
	object.add_to_group("buildable")
	object.set_meta("build_type", "tower2")
	add_child(object)

func show_tower2():
	var preview = Tower2PreviewScene.instantiate()
	add_child(preview)
	return preview

func spawn_wall(position: Vector3, rot_y: float = 0.0):
	var object = WallScene.instantiate()
	object.global_transform.origin = position
	object.rotation.y = rot_y
	object.add_to_group("buildable")
	object.set_meta("build_type", "wall")
	add_child(object)

func show_wall():
	var preview = WallPreviewScene.instantiate()
	add_child(preview)
	return preview

func spawn_slope_wall(position: Vector3, rot_y: float = 0.0):
	var object = SlopeWallScene.instantiate()
	object.global_transform.origin = position
	object.rotation.y = rot_y
	object.add_to_group("buildable")
	object.set_meta("build_type", "slope_wall")
	add_child(object)

func show_slope_wall():
	var preview = SlopeWallPreviewScene.instantiate()
	add_child(preview)
	return preview

func _ready():
	get_tree().paused = false
	$player/GameMenu/stop/Panel.visible = false
	$player/GameMenu/stop/PoleBitwyMenu.visible = false
	
	if Global.selected_map != "res://scenes/świat.tscn" and Global.selected_map != "":
		$"świat".queue_free()
		await get_tree().process_frame
		var map2 = load(Global.selected_map).instantiate()
		map2.name = "świat"
		add_child(map2)
		await get_tree().process_frame
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
			Global.do_win = 1
			get_tree().change_scene_to_file("res://scenes/endgame.tscn")
		else:
			start_wave()
		
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			toggle_pause() #pauzuje grę

func toggle_pause():
	var menu = $player/GameMenu/stop/Panel
	var image = $player/GameMenu/stop/PoleBitwyMenu

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
		"enemies": save_group("enemy"),
		"buildables": save_buildables(),
		"current_wave": current_wave
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
		#print(int(data.get("current_wave", 1)))
		current_wave = int(data.get("current_wave", 1))
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
		load_buildables(data["buildables"])
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

func save_buildables():
	var arr = []

	for node in get_tree().get_nodes_in_group("buildable"):
		if node is Node3D:
			arr.append({
				"type": node.get_meta("build_type"),
				"pos": {
					"x": node.global_position.x,
					"y": node.global_position.y,
					"z": node.global_position.z
				},
				"rot_y": node.rotation.y
			})

	return arr

func load_buildables(data: Array):
	for b in data:
		var pos = Vector3(b["pos"]["x"], b["pos"]["y"], b["pos"]["z"])
		var rot = b.get("rot_y", 0.0)

		match b["type"]:
			"tower1":
				spawn_tower1(pos, rot)
			"tower2":
				spawn_tower2(pos, rot)
			"wall":
				spawn_wall(pos, rot)
			"slope_wall":
				spawn_slope_wall(pos, rot)

func get_random_enemy_scene() -> PackedScene:
	var total_weight = 0

	for weight in spawn_weights:
		total_weight += weight

	var random_value = randi_range(0, total_weight - 1)

	var current_sum = 0

	for i in range(enemy_scenes.size()):
		current_sum += spawn_weights[i]

		if random_value < current_sum:
			return enemy_scenes[i]

	return enemy_scenes[0]
