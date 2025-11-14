extends Area2D

var player_in_range: bool = false
var symbol_game_ui: Control = null

func _ready() -> void:
	var main_scene := get_tree().current_scene
	if main_scene:
		if main_scene.has_node("CanvasLayer/SymbolGame"):
			symbol_game_ui = main_scene.get_node("CanvasLayer/SymbolGame") as Control

			# Connect puzzle solved signal
			symbol_game_ui.puzzle_solved.connect(_on_puzzle_solved)

			print("SymbolGame UI found:", symbol_game_ui)
		else:
			push_warning("No node 'CanvasLayer/SymbolGame' found in Main!")
	else:
		push_warning("No current_scene found!")

	if symbol_game_ui:
		symbol_game_ui.visible = false
		symbol_game_ui.process_mode = Node.PROCESS_MODE_ALWAYS

	print("ExitDoor ready.")


func _on_body_entered(body: Node2D) -> void:
	print("Entered:", body.name)
	if body.name == "Player":
		player_in_range = true
		print("Player entered door area")
		_show_symbol_game()


func _on_body_exited(body: Node2D) -> void:
	print("Exited:", body.name)
	if body.name == "Player":
		player_in_range = false
		print("Player left door area")
		_hide_symbol_game()


func _show_symbol_game() -> void:
	if symbol_game_ui == null:
		push_warning("symbol_game_ui is NULL – cannot show UI!")
		return

	if symbol_game_ui.visible:
		return

	print("Showing SymbolGame UI…")

	# Fullscreen anchors
	symbol_game_ui.anchor_left = 0.0
	symbol_game_ui.anchor_top = 0.0
	symbol_game_ui.anchor_right = 1.0
	symbol_game_ui.anchor_bottom = 1.0
	symbol_game_ui.offset_left = 0.0
	symbol_game_ui.offset_top = 0.0
	symbol_game_ui.offset_right = 0.0
	symbol_game_ui.offset_bottom = 0.0

	symbol_game_ui.visible = true
	symbol_game_ui.z_index = 999


func _hide_symbol_game() -> void:
	if symbol_game_ui == null:
		push_warning("symbol_game_ui is NULL – cannot hide UI!")
		return

	if !symbol_game_ui.visible:
		return

	print("Hiding SymbolGame UI…")
	symbol_game_ui.visible = false


func _on_puzzle_solved() -> void:
	print("Puzzle solved! Opening door soon...")
	# هون لاحقًا منعمل فتح الباب حسب الخيار اللي بتختاره
