extends CanvasLayer

@onready var panel = $InventoryPanel
@onready var grid = $InventoryPanel/GridContainer

const SLOT_COUNT = 28
func _ready():
	panel.visible = false
	grid.columns = 7
	create_slots()

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		panel.visible = !panel.visible

func create_slots():
	for i in range(SLOT_COUNT):
		var slot = Panel.new()
		slot.custom_minimum_size = Vector2(80, 80)
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.2, 0.2, 0.2)
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_width_top = 2
		style.border_width_bottom = 2
		style.border_color = Color.WHITE
		slot.add_theme_stylebox_override("panel", style)
		grid.add_child(slot)
