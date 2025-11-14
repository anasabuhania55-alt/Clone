extends Node

@export var level_time_sec: float = 155              # 3 دقائق
@export var timer_label_path: NodePath                 # اسحب CanvasLayer/TimerLabel
@export var collapse_ui_scene: PackedScene             # اسحب CollapseUI.tscn
@export var collapse_ui_position: Vector2 = Vector2(0,0)

var remaining_time: float
var level_ended: bool = false

var timer_label: Label
var collapse_ui: Control


func _ready() -> void:
	remaining_time = level_time_sec

	# نجيب ليبل الوقت
	if timer_label_path != NodePath(""):
		var n := get_node_or_null(timer_label_path)
		if n is Label:
			timer_label = n
		else:
			push_warning("timer_label_path is not a Label!")
	else:
		push_warning("Assign TimerLabel to timer_label_path!")

	_update_label()


func _process(delta: float) -> void:
	if level_ended:
		return

	remaining_time -= delta
	if remaining_time <= 0.0:
		remaining_time = 0.0
		level_ended = true
		_on_time_over()

	_update_label()


func _update_label() -> void:
	if timer_label:
		var t: int = int(ceil(remaining_time))

		# القسمة الصحيحة الصحيحة في Godot 4
		var minutes: int = int(t / 60)
		var seconds: int = t % 60

		timer_label.text = "%02d:%02d" % [minutes, seconds]

		# 🔥 تلوين النص حسب الوقت المتبقي
		if remaining_time <= 10.0:
			timer_label.modulate = Color(1, 0, 0)      # أحمر
		elif remaining_time <= 30.0:
			timer_label.modulate = Color(1, 1, 0)      # أصفر
		else:
			timer_label.modulate = Color(1, 1, 1)      # أبيض


func _on_time_over() -> void:
	print("Time over! Map collapsed!")

	# نوقف اللعبة
	get_tree().paused = true

	# نضيف واجهة الانهيار
	if collapse_ui_scene:
		collapse_ui = collapse_ui_scene.instantiate()
		var canvas := get_tree().current_scene.get_node("CanvasLayer")
		canvas.add_child(collapse_ui)
		collapse_ui.position = collapse_ui_position
	else:
		push_warning("collapse_ui_scene NOT assigned!")


func end_level_success() -> void:
	level_ended = true
