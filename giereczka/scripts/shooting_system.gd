# PlayerGun.gd
extends Node3D

@export var fire_rate: float = 6.0        # strzały na sekundę (0 = single-shot kontrolowany przez input)
@export var recoil_strength: float = 0.06
@export var bullet_scene: PackedScene     # w inspectorze wstaw PackedScene (Bullet.tscn)
@export var muzzle_offset: NodePath       # ścieżka do Marker3D/Position3D pokazującego wylot lufy
@export var camera: NodePath              # ścieżka do Camera3D używanej do celowania
@export var use_hitscan: bool = true      # true = instant hit (raycast), false = spawn projectile
@export var max_range: float = 200.0
@export var damage: int = 25
@export var ammo_capacity: int = 30
@export var reload_time: float = 1.6

var _time_since_last_shot: float = 0.0
var _cooldown: float = 0.0
var _current_ammo: int
var _is_reloading: bool = false

func _ready():
	_current_ammo = ammo_capacity
	_cooldown = 1.0 / fire_rate if fire_rate > 0 else 0
	if muzzle_offset == null or camera == null:
		push_warning("Ustaw 'muzzle_offset' i 'camera' w inspektorze.")

func _process(delta):
	if _is_reloading:
		return
	_time_since_last_shot += delta

	# obsługa strzału (lewy przycisk myszy)
	if Input.is_action_pressed("shoot"):
		# jeśli fire_rate==0 => single shot triggered by just pressed
		if fire_rate <= 0:
			if Input.is_action_just_pressed("shoot"):
				_try_shoot()
		else:
			if _time_since_last_shot >= _cooldown:
				_try_shoot()

	# reload
	if Input.is_action_just_pressed("reload"):
		if _current_ammo < ammo_capacity and not _is_reloading:
			_start_reload()

func _try_shoot():
	if _is_reloading:
		return
	if _current_ammo <= 0:
		_on_empty_click()
		return

	_time_since_last_shot = 0.0
	_current_ammo -= 1

	# Pozycja i kierunek:
	var cam = get_node_or_null(camera) as Camera3D
	var muzzle = get_node_or_null(muzzle_offset) as Node3D
	if not cam or not muzzle:
		push_error("Brak kamery lub muzzle_offset")
		return

	var from = cam.global_transform.origin
	var dir = -cam.global_transform.basis.z      # w Godot 4: forward dla kamery to -z
	# lekki rozrzut (opcjonalnie)
	dir = dir.rotated(cam.global_transform.basis.x, randf_range(-0.005, 0.005))
	dir = dir.rotated(cam.global_transform.basis.y, randf_range(-0.005, 0.005))

	if use_hitscan:
		_do_hitscan(from, dir)
	else:
		_spawn_projectile(muzzle.global_transform.origin, dir)

	_apply_recoil()
	# tu możesz dodać dźwięk, animację itp.
	_emit_shot_effects(muzzle.global_transform.origin)

func _do_hitscan(from: Vector3, dir: Vector3):
	var space_state = get_world_3d().direct_space_state
	var to = from + dir * max_range

	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	query.collision_mask = 0x7fffffff

	var result = space_state.intersect_ray(query)

	if result:
		_on_hit(result)


func _on_hit(hit_info: Dictionary):
	# hit_info zawiera: position, normal, collider, rid, shape
	var pos = hit_info.position
	var collider = hit_info.collider
	# Jeśli obiekt ma metodę "apply_damage" — wywołaj ją:
	if collider and collider.has_method("apply_damage"):
		collider.apply_damage(damage)

	# efekty trafienia (cząsteczki, decal)
	_spawn_hit_effect(pos, hit_info.normal)

func _spawn_projectile(origin: Vector3, dir: Vector3):
	if bullet_scene == null:
		push_warning("Brak bullet_scene — ustaw PackedScene dla pocisku.")
		return
	var bullet = bullet_scene.instantiate()
	if bullet is Node3D:
		bullet.global_transform = Transform3D(Basis(), origin)
		get_tree().current_scene.add_child(bullet)
		# ustaw velocity / direction na pocisku (o ile ma metodę set_direction)
		if bullet.has_method("set_direction"):
			bullet.set_direction(dir)

func _apply_recoil():
	# proste przesunięcie kamery / ang. recoil — możesz to rozbudować
	var cam = get_node_or_null(camera) as Camera3D
	if cam:
		# prosty pitch up
		cam.rotate_x(-recoil_strength)

func _emit_shot_effects(muzzle_pos: Vector3):
	# Możesz wywołać dźwięk, cząsteczki itp.
	# przykład: emit_signal("shot_fired", muzzle_pos)
	pass

func _spawn_hit_effect(position: Vector3, normal: Vector3):
	# Placeholder: odpal tu particles, decal, dźwięk
	# np. instantiate predefiniowanego hit effect
	pass

func _on_empty_click():
	# np. klik kiedy brak amunicji -> pusto dźwięk
	# print("Brak amunicji")
	pass

func _start_reload():
	_is_reloading = true
	# prosty timer reload
	var t := Timer.new()
	t.wait_time = reload_time
	t.one_shot = true
	add_child(t)
	t.start()
	t.timeout.connect(_on_reload_finished)

func _on_reload_finished():
	_current_ammo = ammo_capacity
	_is_reloading = false
