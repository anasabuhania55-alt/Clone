extends Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS   # خليه يشتغل حتى مع الـ pause

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
