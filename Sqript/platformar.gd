extends StaticBody2D   # غيّرها لـ Node2D إذا الـ root عندك Node2D

var total_torches: int = 0
var lit_torches: int = 0

@onready var sprite1: Sprite2D = $Sprite2D
@onready var sprite2: Sprite2D = $Sprite2D2
@onready var col: CollisionShape2D = $CollisionShape2D
@onready var occluder: LightOccluder2D = $LightOccluder2D   # ← هذا الجديد


func _ready() -> void:
	# بالبداية المنصّة مخفية وما فيها كوليجن ولا ظل
	_show_platform(false)

	# نجيب كل التورشات من الجروب "Torches"
	var torches = get_tree().get_nodes_in_group("Torches")
	total_torches = torches.size()
	print("Platformar: found torches = ", total_torches)

	for torch in torches:
		torch.torch_lit.connect(_on_torch_lit)


func _on_torch_lit() -> void:
	lit_torches += 1
	print("Platformar: lit torches =", lit_torches, "/", total_torches)

	if lit_torches >= total_torches and total_torches > 0:
		_show_platform(true)


func _show_platform(visible: bool) -> void:
	sprite1.visible = visible
	sprite2.visible = visible
	col.disabled = not visible
	occluder.visible = visible        # ← إخفاء/إظهار الظل مع المنصة
	# لو حابب تتأكد أكثر:
	# occluder.sdf_collision = visible
