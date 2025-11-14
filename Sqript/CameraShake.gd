extends Camera2D

@export var shake_interval: float = 15.0        # كل كم ثانية نعمل الهزة
@export var shake_duration: float = 1.5         # مدة الاهتزاز
@export var shake_strength: float = 3.0         # قوة الاهتزاز

var is_shaking: bool = false
var shake_timer: float = 0.0
var original_offset := Vector2.ZERO

@onready var shake_sound: AudioStreamPlayer2D = $ShakeSound   # ← الصوت


func _ready() -> void:
	original_offset = offset
	set_process(true)
	shake_timer = shake_interval


func _process(delta: float) -> void:
	shake_timer -= delta
	if shake_timer <= 0.0:
		_start_shake()
		shake_timer = shake_interval

	if is_shaking:
		shake_duration -= delta

		if shake_duration > 0:
			offset = original_offset + Vector2(
				randf_range(-shake_strength, shake_strength),
				randf_range(-shake_strength, shake_strength)
			)
		else:
			offset = original_offset
			is_shaking = false


func _start_shake() -> void:
	is_shaking = true
	shake_duration = 0.4

	shake_sound.play()       # 🔥 ← تشغيل صوت الهزة هنا
