extends Control

var do_win = null
var played_sound = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Make sure the mouse is visible so the player can click the buttons
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Global.do_win:
		$win.visible = true
		$lose.visible = false
		$WinSound.play()
	else:
		$win.visible = false
		$lose.visible = true
		$LoseSound.play() 

func _on_new_game_pressed() -> void:
	Global.load_game = false
	get_tree().change_scene_to_file("res://main.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")
