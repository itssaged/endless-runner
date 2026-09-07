extends CharacterBody3D

signal player_died

@export var run_speed: float = 0.0

var positions = [-2.5, 1, 4]
var cur_pos = 1
var gravitiy = 64
var jump_vel = 16

var is_jumping: bool = false
var is_dead: bool = false


# =========================
# TURN
# =========================

var base_rotation_y: float = PI

@export var turn_angle: float = 45.0

var turn_speed: float = 10.0

var target_turn: float = 0.0


# =========================
# FBX NODES
# =========================

@onready var node_run: Node3D = $"Fast Run"
@onready var node_jump: Node3D = $"Jumping"
@onready var node_die: Node3D = $"Dying Backwards"

@onready var anim_run: AnimationPlayer = $"Fast Run/AnimationPlayer"
@onready var anim_jump: AnimationPlayer = $"Jumping/AnimationPlayer"
@onready var anim_die: AnimationPlayer = $"Dying Backwards/AnimationPlayer"

@onready var camera_controller: Node3D = $camera_controller
@onready var ray_cast_3d: RayCast3D = $RayCast3D


func _ready() -> void:

	if node_run:
		node_run.rotation.y = PI

	if node_jump:
		node_jump.rotation.y = PI

	if node_die:
		node_die.rotation.y = PI


	# =========================
	# CAMERA
	# =========================

	if camera_controller:
		camera_controller.position = Vector3(0, 2.5, 4.0)


	# =========================
	# RUN ANIMATION LOOP
	# =========================

	if anim_run:

		var run_anim_name = _get_first_anim_name(anim_run)

		if run_anim_name != "":

			var run_anim = anim_run.get_animation(run_anim_name)

			if run_anim:
				run_anim.loop_mode = Animation.LOOP_LINEAR


	# =========================
	# JUMP ANIMATION
	# =========================

	if anim_jump:

		var jump_anim_name = _get_first_anim_name(anim_jump)

		if jump_anim_name != "":

			var jump_anim = anim_jump.get_animation(jump_anim_name)

			if jump_anim:
				jump_anim.length = jump_anim.length * 0.3


	# =========================
	# JUMP FINISHED
	# =========================

	if anim_jump:

		if not anim_jump.animation_finished.is_connected(_on_jump_finished):

			anim_jump.animation_finished.connect(_on_jump_finished)


	# =========================
	# START RUNNING
	# =========================

	_play_animation(anim_run, node_run)


func _physics_process(delta: float) -> void:

	if is_dead:
		return


	# =========================
	# FORWARD MOVEMENT
	# =========================

	# اللاعب لا يتحرك على Z
	velocity.z = 0.0


	# =========================
	# CHANGE LANES
	# =========================

	if Input.is_action_just_pressed("left"):

		if cur_pos < 2:

			$turn.play()

			cur_pos += 1

			target_turn = deg_to_rad(turn_angle)


	elif Input.is_action_just_pressed("right"):

		if cur_pos > 0:

			$turn.play()

			cur_pos -= 1

			target_turn = deg_to_rad(-turn_angle)


	# =========================
	# MOVE TO NEW LANE
	# =========================

	position.x = lerpf(
		position.x,
		positions[cur_pos],
		delta * 30.0
	)


	# =========================
	# TURN PLAYER
	# =========================

	rotation.y = lerp_angle(
		rotation.y,
		base_rotation_y + target_turn,
		delta * turn_speed
	)


	# =========================
	# CAMERA COUNTER ROTATION
	# =========================

	if camera_controller:

		var current_turn_amount = rotation.y - base_rotation_y

		camera_controller.rotation.y = -current_turn_amount


	# =========================
	# RETURN TO STRAIGHT
	# =========================

	target_turn = lerp(
		target_turn,
		0.0,
		delta * 8.0
	)


	# =========================
	# JUMP
	# =========================

	if is_on_floor():

		velocity.y = 0.0

		if Input.is_action_just_pressed("up") and not is_jumping:

			is_jumping = true

			velocity.y = jump_vel

			$jump.play()

			_play_animation(
				anim_jump,
				node_jump
			)

	else:

		velocity.y -= gravitiy * delta


	# =========================
	# CAMERA
	# =========================

	if camera_controller:

		camera_controller.position.x = lerp(
			camera_controller.position.x,
			0.0,
			delta * 10.0
		)


	# =========================
	# RAYCAST
	# =========================

	if ray_cast_3d and ray_cast_3d.is_colliding():

		var hit: Node = ray_cast_3d.get_collider() as Node

		if hit:

			if hit.is_in_group("desk"):

				print("DESK HIT!")

				player_died.emit()

				die()

				return


	# =========================
	# MOVE
	# =========================

	move_and_slide()


# =========================
# DIE
# =========================

func die() -> void:

	if is_dead:
		return

	is_dead = true


	if anim_run:
		anim_run.stop()

	if anim_jump:
		anim_jump.stop()

	if node_run:
		node_run.visible = false

	if node_jump:
		node_jump.visible = false

	if node_die:
		node_die.visible = true


	if anim_die:

		var die_anim_name = _get_first_anim_name(anim_die)

		if die_anim_name != "":

			var die_anim = anim_die.get_animation(die_anim_name)

			if die_anim:

				anim_die.stop()

				anim_die.speed_scale = 2.0

				anim_die.play(die_anim_name)

				anim_die.seek(
					die_anim.length * 0.25,
					true
				)


	Global.game_on = false

	velocity = Vector3.ZERO

	set_physics_process(false)


# =========================
# GET FIRST ANIMATION
# =========================

func _get_first_anim_name(
	player_node: AnimationPlayer
) -> String:

	if player_node:

		var anim_list = player_node.get_animation_list()

		if anim_list.size() > 0:

			return anim_list[0]

	return ""


# =========================
# PLAY ANIMATION
# =========================

func _play_animation(
	target_anim: AnimationPlayer,
	active_node: Node3D
) -> void:

	if anim_run:
		anim_run.stop()

	if anim_jump:
		anim_jump.stop()

	if anim_die:
		anim_die.stop()


	if node_run:
		node_run.visible = false

	if node_jump:
		node_jump.visible = false

	if node_die:
		node_die.visible = false


	if active_node:
		active_node.visible = true


	if target_anim:

		var anim_name = _get_first_anim_name(target_anim)

		if anim_name != "":

			target_anim.speed_scale = 1.0

			target_anim.play(
				anim_name,
				0.1
			)


# =========================
# JUMP FINISHED
# =========================

func _on_jump_finished(
	_anim_name: StringName
) -> void:

	is_jumping = false

	if not is_dead:

		_play_animation(
			anim_run,
			node_run
	)
