extends Control
signal puzzle_solved

@export var symbol_textures: Array[Texture2D]
@export_file("*.tscn") var win_scene_path: String = ""   # ← اسحب مشهد الفوز من الإنسبيكتور

var correct_indices: Array[int] = []      # ← RuneManager يضبط هذا
var selected_buttons: Array[Button] = []

@onready var grid: GridContainer = $VBoxContainer/SymbolsGrid
@onready var result_label: Label = $VBoxContainer/ResultLabel
@onready var reset_button: Button = $VBoxContainer/ResetButton


func _ready() -> void:
	randomize()
	_create_symbol_buttons()
	reset_button.pressed.connect(_on_reset_pressed)


func _create_symbol_buttons() -> void:
	for child in grid.get_children():
		child.queue_free()

	selected_buttons.clear()
	result_label.text = ""

	var count: int = min(10, symbol_textures.size())

	for i in count:
		var btn := Button.new()
		btn.toggle_mode = true
		btn.text = ""
		btn.icon = symbol_textures[i]
		btn.expand_icon = true
		btn.set_meta("index", i)
		btn.custom_minimum_size = Vector2(80, 80)

		btn.pressed.connect(func():
			_on_symbol_pressed(btn)
		)

		grid.add_child(btn)


func _on_symbol_pressed(button: Button) -> void:
	var _idx = button.get_meta("index")

	if button.button_pressed:
		if selected_buttons.size() >= 3:
			button.button_pressed = false
			result_label.text = "You can only select 3 symbols!"
			return
		selected_buttons.append(button)
	else:
		selected_buttons.erase(button)

	if result_label.text != "You win! 🎉":
		result_label.text = ""

	if selected_buttons.size() == 3:
		_check_answer()


func _check_answer() -> void:
	var selected_indices: Array[int] = []
	for btn in selected_buttons:
		selected_indices.append(btn.get_meta("index"))

	selected_indices.sort()
	var correct_sorted := correct_indices.duplicate()
	correct_sorted.sort()

	if selected_indices == correct_sorted:
		result_label.text = "You win! 🎉"
		_highlight_buttons(true)
		emit_signal("puzzle_solved")

		# 🔻 هنا الانتقال لمشهد الفوز
		if win_scene_path != "":
			get_tree().change_scene_to_file(win_scene_path)

	else:
		result_label.text = "Wrong! ❌"
		_highlight_buttons(false)
		await get_tree().create_timer(1.0).timeout
		_clear_selection()


func _highlight_buttons(correct: bool) -> void:
	for btn in selected_buttons:
		btn.modulate = Color(0,1,0) if correct else Color(1,0,0)


func _clear_selection() -> void:
	for child in grid.get_children():
		if child is Button:
			child.button_pressed = false
			child.modulate = Color(1,1,1)

	selected_buttons.clear()


func _on_reset_pressed() -> void:
	_clear_selection()
	result_label.text = ""


func _on_reset_button_pressed() -> void:
	pass # Replace with function body.
