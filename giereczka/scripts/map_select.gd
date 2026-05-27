extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_map_1_pressed() -> void:
	print("kliknieto mapa 1")
	Global.selected_map = "res://scenes/świat.tscn"
	get_tree().change_scene_to_file("res://main.tscn")


func _on_map_2_pressed() -> void:
	Global.selected_map = "res://swiat2.tscn"
	get_tree().change_scene_to_file("res://main.tscn")
	


func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")
