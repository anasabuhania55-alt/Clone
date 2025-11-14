extends CharacterBody2D

@export var speed: float = 120.0
@export var jump_velocity: float = -220.0
@export var clone_scene: PackedScene
@export var clone_offset_x: float = 16.0
@export var clone_back_offset_x: float = 6.0
@export var max_clones: int = 14

@export var clone_counter_path: NodePath

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_clone: Node2D = null
var clone_uses: int = 0
var is_dead: bool = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var clone_ray: RayCast2D = $CloneSpawnRay
@onready var spawn_sound: AudioStreamPlayer2D = $CloneSound
@onready var remove_sound: AudioStreamPlayer2D = $CloneRemoveSound     # ← الصوت الجديد

var clone_counter_label: Label


func _ready() -> void:
	# Get clone counter label
	if clone_counter_path != NodePath(""):
		var node := get_node_or_null(clone_counter_path)
		if node and node is Label:
			clone_counter_label = node
			print("CloneCounter label FOUND:", clone_counter_label.name)
			clone_counter_label.visible = true
		else:
			push_warning("clone_counter_path is set but not a Label!")
	else:
		push_warning("clone_counter_path is EMPTY! Set CanvasLayer/CloneCounter.")

	update_clone_counter()


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Movement
	var dir := Input.get_action_strength("MoveR") - Input.get_action_strength("MoveL")
	velocity.x = dir * speed

	# Flip sprite
	if dir != 0.0:
		anim.flip_h = dir < 0.0

	# Jump
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = jump_velocity
		anim.play("Jump")

	# Animations
	if not is_on_floor():
		anim.play("Jump")
	else:
		if abs(velocity.x) < 1.0:
			anim.play("Idle")
		else:
			anim.play("Walk")

	move_and_slide()

	# -----------------------------------------------------
	# Clone Input
	# -----------------------------------------------------
	if Input.is_action_just_pressed("clone") and clone_scene:

		# إذا النسخة موجودة → إحذفها + صوت الإرجاع
		if is_instance_valid(current_clone):
			remove_sound.play()              # ← شغل صوت الحذف
			current_clone.queue_free()
			current_clone = null
			return

		# إذا ما في نسخة → اعمل Spawn
		if clone_uses >= max_clones:
			_die()
			return

		clone_uses += 1
		update_clone_counter()

		# تحديد مكان Spawn
		var facing_dir := -1.0 if anim.flip_h else 1.0
		var front_offset := Vector2(clone_offset_x * facing_dir, 0)
		var spawn_pos := global_position + front_offset
		var can_spawn := true

		clone_ray.target_position = front_offset
		clone_ray.force_raycast_update()

		if clone_ray.is_colliding():
			var opposite_dir := -facing_dir
			var back_offset := Vector2(clone_back_offset_x * opposite_dir, 0)
			var back_pos := global_position + back_offset

			clone_ray.target_position = back_offset
			clone_ray.force_raycast_update()

			if clone_ray.is_colliding():
				can_spawn = false
				print("Spawn blocked on both sides.")
			else:
				spawn_pos = back_pos

		if not can_spawn:
			return

		# Safe distance
		if global_position.distance_to(spawn_pos) < 12.0:
			var dir_vec := (spawn_pos - global_position).normalized()
			spawn_pos = global_position + dir_vec * 12.0

		# Spawn the clone
		var clone := clone_scene.instantiate()
		spawn_sound.play()                  # ← شغل صوت Spawn
		get_tree().current_scene.add_child(clone)
		clone.global_position = spawn_pos

		current_clone = clone

		clone.tree_exited.connect(func():
			if current_clone == clone:
				current_clone = null
		)

		if clone.has_method("apply_pose"):
			clone.apply_pose(anim.sprite_frames, anim.animation, anim.frame, anim.flip_h)


func update_clone_counter() -> void:
	if clone_counter_label:
		clone_counter_label.text = "Clones: %d/%d" % [clone_uses, max_clones]

		var remaining := max_clones - clone_uses

		if remaining <= 2:
			clone_counter_label.modulate = Color(1, 0, 0)     # أحمر
		elif remaining <= 5:
			clone_counter_label.modulate = Color(1, 1, 0)     # أصفر
		else:
			clone_counter_label.modulate = Color(1, 1, 1)     # أبيض

	else:
		print("clone_counter_label is NULL in update_clone_counter()!")



func _die() -> void:
	if is_dead:
		return

	is_dead = true
	velocity = Vector2.ZERO
	anim.play("Death")

	await anim.animation_finished

	get_tree().reload_current_scene()
