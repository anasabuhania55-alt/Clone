extends Area2D

signal torch_lit

var is_lit: bool = false

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var light2d: PointLight2D = $PointLight2D

func _ready() -> void:
	light2d.visible = false
	anim.stop()
	add_to_group("Torches")  # مهم عشان المنصّة أو العداد يلقاهم

func _physics_process(_delta: float) -> void:
	if is_lit:
		return

	var detector := get_tree().get_root().find_child("LightDetector", true, false)
	if detector and detector.overlaps_area(self):
		_light_torch()

func _light_torch() -> void:
	if is_lit:
		return

	is_lit = true
	light2d.visible = true
	anim.play("FlameOn")
	emit_signal("torch_lit")
