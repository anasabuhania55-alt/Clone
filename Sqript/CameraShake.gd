extends Camera2D

@export var base_interval: float = 15.0        # أكبر فترة بين الهزّات (وقت كثير)
@export var min_interval: float = 1.0          # أقل فترة (قبل الانهيار)
@export var base_strength: float = 2.0         # قوة الهزّة العادية
@export var max_strength: float = 8.0          # قوة الهزّة القصوى
@export var level_timer_path: NodePath         # اسحب نود LevelTimer من المشهد

var shake_timer: float = 0.0
var is_shaking: bool = false
var shake_time: float = 0.0
var original_offset: Vector2
var timer_node: Node = null

@onready var shake_sound: AudioStreamPlayer2D = $ShakeSound


func _ready() -> void:
	original_offset = offset
	set_process(true)

	# نجيب نود التايمر
	if level_timer_path != NodePath(""):
		timer_node = get_node_or_null(level_timer_path)
		if timer_node == null:
			push_warning("LevelTimer not found at level_timer_path!")
	else:
		push_warning("Assign LevelTimer node to level_timer_path in the inspector!")

	shake_timer = base_interval


func _process(delta: float) -> void:
	if timer_node == null:
		return

	# نقرأ الوقت المتبقي والقيمة الكلية من LevelTimer
	var remaining: float = timer_node.remaining_time
	var total: float = timer_node.level_time_sec

	# نسبة الوقت (1 = الوقت كامل، 0 = انتهى)
	var percent: float = clamp(remaining / total, 0.0, 1.0)

	# كل ما قل الوقت → الهزة تصير أقرب
	var current_interval: float = lerp(min_interval, base_interval, percent)

	# كل ما قل الوقت → قوة الهزة تزيد
	var current_strength: float = lerp(max_strength, base_strength, percent)

	# عد تنازلي للوقت بين الهزات
	shake_timer -= delta
	if shake_timer <= 0.0:
		_start_shake()
		shake_timer = current_interval

	# تنفيذ الاهتزاز نفسه
	if is_shaking:
		shake_time -= delta
		if shake_time > 0.0:
			offset = original_offset + Vector2(
				randf_range(-current_strength, current_strength),
				randf_range(-current_strength, current_strength)
			)
		else:
			offset = original_offset
			is_shaking = false


func _start_shake() -> void:
	is_shaking = true
	shake_time = 0.3          # مدة كل هزة
	shake_sound.play()
