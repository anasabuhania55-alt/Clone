extends Control

# Called when the node enters the scene tree for the first time.

# --- Button Functions ---
func _on_start_pressed() -> void:
	print("Start button pressed")
	# Replace with your game scene path
	get_tree().change_scene_to_file("res://Scene/main.tscn")


func _on_quit_pressed() -> void:
	print("Quit button pressed")
	get_tree().quit()
