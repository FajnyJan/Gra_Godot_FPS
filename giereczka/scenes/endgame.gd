extends Control

var do_win = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	do_win = Global.do_win

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if do_win:
		$win.visible = true
	else:
		$lose.visible = true


func _on_new_game_pressed() -> void:
	Global.load_game = false
	get_tree().change_scene_to_file("res://main.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
