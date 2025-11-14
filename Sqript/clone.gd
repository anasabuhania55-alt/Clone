extends StaticBody2D

@export var lifetime: float = 8.0   # seconds; set to 0 for permanent

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	if lifetime > 0.0:
		var t := Timer.new()
		t.one_shot = true
		t.wait_time = lifetime
		add_child(t)
		t.start()
		t.timeout.connect(func():
			queue_free()
		)

# Called by Player.gd right after spawn
func apply_pose(frames: SpriteFrames, animation: String, frame: int, flip_h: bool) -> void:
	anim.sprite_frames = frames
	anim.animation = animation
	anim.frame = frame
	anim.flip_h = flip_h
	anim.stop()  # freeze on current frame
