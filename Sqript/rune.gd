extends Area2D

signal rune_revealed
signal rune_hidden   # إشارة إضافية لو بدك تستخدمها لاحقاً

var revealed: bool = false

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	sprite.visible = false
	add_to_group("Runes")


func _process(_delta: float) -> void:
	var detector := get_tree().get_root().find_child("LightDetector", true, false)

	if detector and detector.overlaps_area(self):
		# الضوء موجود → الرون يظهر
		if not revealed:
			revealed = true
			sprite.visible = true
			emit_signal("rune_revealed")
	else:
		# الضوء غير موجود → الرون يختفي
		if revealed:
			revealed = false
			sprite.visible = false
			emit_signal("rune_hidden")
