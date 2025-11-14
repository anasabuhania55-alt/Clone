extends Node

@export var rune_scenes: Array[PackedScene]
@export var rune_counter_path: NodePath   # اسحب CanvasLayer/RuneCounter من الإنسبيكتور

var chosen_rune_indices: Array[int] = []   # الرموز الصحيحة (إندكسات من 0..9)

var total_runes: int = 0
var revealed_runes_count: int = 0
var rune_counter_label: Label


func _ready() -> void:
	# نجيب الليبل
	if rune_counter_path != NodePath(""):
		var node := get_node_or_null(rune_counter_path)
		if node is Label:
			rune_counter_label = node
		else:
			push_warning("rune_counter_path is not a Label!")
	else:
		push_warning("rune_counter_path is empty! Assign CanvasLayer/RuneCounter.")

	randomize()
	spawn_random_runes()


func spawn_random_runes():
	# ---------------------------------------
	# 1 — أماكن السبون
	# ---------------------------------------
	var spot1 = get_parent().get_node("RuneSpot1")
	var spot2 = get_parent().get_node("RuneSpot2")
	var spot3 = get_parent().get_node("RuneSpot3")
	var spots = [spot1, spot2, spot3]

	# ---------------------------------------
	# 2 — اختيار 3 رونات بدون تكرار
	# ---------------------------------------
	var shuffled := rune_scenes.duplicate()
	shuffled.shuffle()

	var chosen_scenes = shuffled.slice(0, 3)  # الثلاث مشاهد
	chosen_rune_indices.clear()

	for scene in chosen_scenes:
		var idx = rune_scenes.find(scene)
		chosen_rune_indices.append(idx)

	print("Correct runes =", chosen_rune_indices)

	# ---------------------------------------
	# 3 — توزيع الرونات على السبوتس بشكل عشوائي
	# ---------------------------------------
	spots.shuffle()

	revealed_runes_count = 0
	total_runes = chosen_scenes.size()

	for i in range(total_runes):
		var rune_instance = chosen_scenes[i].instantiate()
		spots[i].add_child(rune_instance)
		rune_instance.position = Vector2.ZERO

		# نربط إشارة الكشف
		if rune_instance.has_signal("rune_revealed"):
			rune_instance.rune_revealed.connect(_on_rune_revealed)

	# ---------------------------------------
	# 4 — إرسال الحل إلى SymbolGame
	# ---------------------------------------
	var symbol_game = get_parent().get_node("CanvasLayer/SymbolGame")
	symbol_game.correct_indices = chosen_rune_indices.duplicate()

	_update_rune_counter()


func _on_rune_revealed() -> void:
	revealed_runes_count += 1
	_update_rune_counter()


func _update_rune_counter() -> void:
	if rune_counter_label:
		rune_counter_label.text = "Runes: " + str(revealed_runes_count) + "/" + str(total_runes)
