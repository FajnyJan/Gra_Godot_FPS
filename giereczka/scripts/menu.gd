extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/Start.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
	


func _on_option_pressed() -> void:
	pass #moze jakies opcje dodac lol


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_continue_pressed() -> void:
	pass # zamienic z funkcją która będzie wczytywać zapisny plik
