extends CanvasLayer

@onready var story_label: Label = $VBoxContainer/Label

# الجمل: كل عنصر = سطرين
var story_lines := [
	"The stone forgets the light it kept\nThe Ancient Vault where shadows slept.",
	"A princely soul, now merely Shade\nTrapped by the oath the sorcerer made.",
	"Listen close! The Earth is Rift\nBefore the final stone shall shift.",
	"Your prison crumbles, dark and fast\nYour true form broken, doomed to last...",
	"UNLESS you summon what you lack-\nA legion forged that will fight back.",
	"For every step, a copy cast\nYou are the key, the first, the last.",
	"Forge your path out of the deep\nBefore the shadows rise and leap."
]

var current_index := 0

# مدة الفيد
@export var fade_time := 1.2
@export var wait_time := 2.0

func _ready():
	process_next_line()


func process_next_line():
	if current_index >= story_lines.size():
		_load_first_level()
		return

	# ضع النص الجديد
	story_label.text = story_lines[current_index]
	story_label.modulate = Color(1,1,1,0)

	# ابدأ الفيد إن
	fade_in()



func fade_in():
	var tween := create_tween()
	tween.tween_property(story_label, "modulate:a", 1.0, fade_time)
	tween.tween_callback(Callable(self, "_wait_after_fade_in"))


func _wait_after_fade_in():
	var t := get_tree().create_timer(wait_time)
	await t.timeout
	fade_out()


func fade_out():
	var tween := create_tween()
	tween.tween_property(story_label, "modulate:a", 0.0, fade_time)
	tween.tween_callback(Callable(self, "_on_fade_out_complete"))


func _on_fade_out_complete():
	current_index += 1
	process_next_line()


func _load_first_level():
	get_tree().change_scene_to_file("res://Scene/LightClone.tscn")
