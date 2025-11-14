extends Node

@export var torch_counter_path: NodePath   # اسحب TorchCounter من الإنسبيكتور

var total_torches: int = 0
var lit_torches: int = 0

var torch_counter_label: Label


func _ready() -> void:
	# نجيب الليبل
	if torch_counter_path != NodePath(""):
		var node := get_node_or_null(torch_counter_path)
		if node is Label:
			torch_counter_label = node
		else:
			push_warning("torch_counter_path is not a Label!")
	else:
		push_warning("torch_counter_path is empty! Assign CanvasLayer/TorchCounter.")

	# نجيب كل التورشات من الجروب "Torches"
	var torches = get_tree().get_nodes_in_group("Torches")
	total_torches = torches.size()

	for torch in torches:
		torch.torch_lit.connect(_on_torch_lit)

	_update_label()


func _on_torch_lit() -> void:
	lit_torches += 1
	_update_label()


func _update_label() -> void:
	if torch_counter_label:
		torch_counter_label.text = "Torches: " + str(lit_torches) + "/" + str(total_torches)
