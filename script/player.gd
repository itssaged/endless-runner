extends CharacterBody3D

signal player_died

@export var run_speed: float = 0.0


# =========================================================
# CHICKEN
# =========================================================

@onready var chicken: Node3D = $chicken

@onready var fast_run__1_: Node3D = $"chicken/Fast Run (1)"
@onready var jump_attack__1_: Node3D = $"chicken/Jump Attack (1)"

@onready var fast_run_anim: AnimationPlayer = $"chicken/Fast Run (1)/AnimationPlayer"
@onready var jump_attack_anim: AnimationPlayer = $"chicken/Jump Attack (1)/AnimationPlayer"


# =========================================================
# LANES
# =========================================================

var positions = [-2.5, 1, 4]
var cur_pos = 1


# =========================================================
# GRAVITY / JUMP
# =========================================================

var gravitiy = 64
var jump_vel = 16

@export var fast_fall_gravity: float = 180.0

var is_jumping: bool = false
var is_dead: bool = false


# =========================================================
# RUN ANIMATION SPEED
# =========================================================

@export var min_run_anim_speed: float = 0.5
@export var max_run_anim_speed: float = 2.4


# =========================================================
# TURN
# =========================================================

var base_rotation_y: float = PI

@export var turn_angle: float = 45.0

var turn_speed: float = 10.0

var target_turn: float = 0.0


# =========================================================
# PLAYER FBX NODES
# =========================================================

@onready var node_run: Node3D = $"Fast Run"
@onready var node_jump: Node3D = $"Jumping"
@onready var node_die: Node3D = $"Dying Backwards"

@onready var anim_run: AnimationPlayer = $"Fast Run/AnimationPlayer"
@onready var anim_jump: AnimationPlayer = $"Jumping/AnimationPlayer"
@onready var anim_die: AnimationPlayer = $"Dying Backwards/AnimationPlayer"


# =========================================================
# CAMERA
# =========================================================

@onready var camera_controller: Node3D = $camera_controller


# =========================================================
# RAYCAST
# =========================================================

@onready var ray_cast_3d: RayCast3D = $RayCast3D


# =========================================================
# DEBUG
# =========================================================

var last_debug_collider: Node = null
var last_debug_time: float = -10.0

@export var debug_cooldown: float = 0.30

# أقل تغيير X نعتبره مهم
@export var debug_x_threshold: float = 0.005


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	if node_run:
		node_run.rotation.y = PI

	if node_jump:
		node_jump.rotation.y = PI

	if node_die:
		node_die.rotation.y = PI

	if camera_controller:
		camera_controller.position = Vector3(0, 2.5, 4.0)


	# =====================================================
	# PLAYER RUN ANIMATION
	# =====================================================

	if anim_run:

		var run_anim_name = _get_first_anim_name(anim_run)

		if run_anim_name != "":

			var run_anim = anim_run.get_animation(run_anim_name)

			if run_anim:
				run_anim.loop_mode = Animation.LOOP_LINEAR


	# =====================================================
	# PLAYER JUMP ANIMATION
	# =====================================================

	if anim_jump:

		var jump_anim_name = _get_first_anim_name(anim_jump)

		if jump_anim_name != "":

			var jump_anim = anim_jump.get_animation(jump_anim_name)

			if jump_anim:
				jump_anim.loop_mode = Animation.LOOP_NONE


	# =====================================================
	# JUMP FINISHED SIGNAL
	# =====================================================

	if anim_jump:

		if not anim_jump.animation_finished.is_connected(_on_jump_finished):
			anim_jump.animation_finished.connect(_on_jump_finished)


	# =====================================================
	# CHICKEN
	# =====================================================

	if fast_run__1_:
		fast_run__1_.visible = true

	if jump_attack__1_:
		jump_attack__1_.visible = false


	# =====================================================
	# CHICKEN RUN ANIMATION
	# =====================================================

	if fast_run_anim:

		var chicken_run_name = _get_first_anim_name(fast_run_anim)

		if chicken_run_name != "":

			var chicken_run = fast_run_anim.get_animation(chicken_run_name)

			if chicken_run:
				chicken_run.loop_mode = Animation.LOOP_LINEAR

			fast_run_anim.speed_scale = 1.0
			fast_run_anim.play(chicken_run_name)


	# =====================================================
	# START PLAYER RUN
	# =====================================================

	_play_animation(anim_run, node_run)


# =========================================================
# PHYSICS
# =========================================================

func _physics_process(delta: float) -> void:

	if is_dead:
		return


	# =====================================================
	# RUN ANIMATION SPEED
	# =====================================================

	if anim_run and not is_jumping:

		var speed_ratio: float = clamp(
			Global.game_speed / Global.max_game_speed,
			0.0,
			1.0
		)

		var run_anim_speed: float = lerpf(
			min_run_anim_speed,
			max_run_anim_speed,
			speed_ratio
		)

		anim_run.speed_scale = run_anim_speed


	# =====================================================
	# RESET HORIZONTAL VELOCITY
	# =====================================================

	velocity.x = 0.0
	velocity.z = 0.0


	# =====================================================
	# LANE LEFT
	# =====================================================

	if Input.is_action_just_pressed("left"):

		if cur_pos < 2:

			$turn.play()

			cur_pos += 1

			target_turn = deg_to_rad(turn_angle)


	# =====================================================
	# LANE RIGHT
	# =====================================================

	elif Input.is_action_just_pressed("right"):

		if cur_pos > 0:

			$turn.play()

			cur_pos -= 1

			target_turn = deg_to_rad(-turn_angle)


	# =====================================================
	# SAVE X BEFORE LANE MOVEMENT
	# =====================================================

	var old_x: float = position.x


	# =====================================================
	# MOVE TO LANE
	# =====================================================

	position.x = lerpf(
		position.x,
		positions[cur_pos],
		delta * 30.0
	)

	var x_before_physics: float = position.x

	var lane_target_x: float = positions[cur_pos]


	# =====================================================
	# PLAYER ROTATION
	# =====================================================

	rotation.y = lerp_angle(
		rotation.y,
		base_rotation_y + target_turn,
		delta * turn_speed
	)


	# =====================================================
	# CAMERA COUNTER ROTATION
	# =====================================================

	if camera_controller:

		var current_turn_amount = rotation.y - base_rotation_y

		camera_controller.rotation.y = -current_turn_amount


	target_turn = lerp(
		target_turn,
		0.0,
		delta * 8.0
	)


	# =====================================================
	# ON FLOOR
	# =====================================================

	if is_on_floor():

		velocity.y = 0.0


		# =================================================
		# LANDED
		# =================================================

		if is_jumping:

			is_jumping = false


			# ---------------------------------------------
			# START CHICKEN RUN AGAIN
			# ---------------------------------------------

			if fast_run_anim:

				var chicken_run_name = _get_first_anim_name(
					fast_run_anim
				)

				if chicken_run_name != "":

					fast_run_anim.speed_scale = 1.0
					fast_run_anim.play(chicken_run_name)


			# ---------------------------------------------
			# START PLAYER RUN
			# ---------------------------------------------

			if not is_dead:

				_play_animation(
					anim_run,
					node_run
				)


		# =================================================
		# JUMP
		# =================================================

		if Input.is_action_just_pressed("up") and not is_jumping:

			is_jumping = true

			velocity.y = jump_vel

			$jump.play()


			# ---------------------------------------------
			# STOP CHICKEN RUN
			# ---------------------------------------------

			if fast_run_anim:
				fast_run_anim.pause()


			# ---------------------------------------------
			# PLAYER JUMP
			# ---------------------------------------------

			_play_animation(
				anim_jump,
				node_jump
			)


	# =====================================================
	# IN AIR
	# =====================================================

	else:

		var current_gravity = gravitiy

		if Input.is_action_pressed("down"):
			current_gravity = fast_fall_gravity

		velocity.y -= current_gravity * delta


		# =================================================
		# KEEP PLAYER JUMP MODEL
		# =================================================

		if is_jumping and not is_dead:

			if node_jump and not node_jump.visible:

				_play_animation(
					anim_jump,
					node_jump
				)


	# =====================================================
	# CAMERA RESET
	# =====================================================

	if camera_controller:

		camera_controller.position.x = lerp(
			camera_controller.position.x,
			0.0,
			delta * 10.0
		)


	# =====================================================
	# RAYCAST
	# =====================================================

	if ray_cast_3d and ray_cast_3d.is_colliding():

		var hit: Node = ray_cast_3d.get_collider() as Node

		if hit:

			if _is_obstacle(hit):

				_debug_raycast_hit(hit)

				player_died.emit()

				die()

				return


	# =====================================================
	# MOVE AND SLIDE
	# =====================================================

	move_and_slide()


	# =====================================================
	# DEBUG AFTER PHYSICS
	# =====================================================

	var x_after_physics: float = position.x

	_debug_lane_movement(
		old_x,
		x_before_physics,
		x_after_physics,
		lane_target_x
	)

	_debug_physics_collision(
		x_before_physics,
		x_after_physics,
		lane_target_x
	)


# =========================================================
# LANE MOVEMENT DEBUG
# =========================================================

func _debug_lane_movement(
	old_x: float,
	x_before_physics: float,
	x_after_physics: float,
	lane_target_x: float
) -> void:

	var physics_x_change: float = (
		x_after_physics - x_before_physics
	)

	if abs(physics_x_change) < debug_x_threshold:
		return

	print("")
	print("========== X MOVEMENT DEBUG ==========")

	print(
		"LANE: ",
		cur_pos,
		" | TARGET X: ",
		lane_target_x
	)

	print(
		"OLD X: ",
		old_x
	)

	print(
		"X BEFORE PHYSICS: ",
		x_before_physics
	)

	print(
		"X AFTER PHYSICS: ",
		x_after_physics
	)

	print(
		"PHYSICS X CHANGE: ",
		physics_x_change
	)

	print(
		"DISTANCE FROM TARGET: ",
		x_after_physics - lane_target_x
	)

	print("======================================")


# =========================================================
# PHYSICS COLLISION DEBUG
# =========================================================

func _debug_physics_collision(
	x_before_physics: float,
	x_after_physics: float,
	lane_target_x: float
) -> void:

	var collision_count: int = get_slide_collision_count()

	if collision_count <= 0:
		return

	for i in range(collision_count):

		var collision: KinematicCollision3D = get_slide_collision(i)

		if collision == null:
			continue

		var normal: Vector3 = collision.get_normal()

		if abs(normal.y) > 0.7:
			continue

		var collider: Object = collision.get_collider()

		if not collider is Node:
			continue

		var collider_node: Node = collider as Node

		var x_change: float = (
			x_after_physics - x_before_physics
		)

		if abs(x_change) < debug_x_threshold:
			continue

		var current_time: float = (
			Time.get_ticks_msec() / 1000.0
		)

		if (
			collider_node == last_debug_collider
			and
			current_time - last_debug_time < debug_cooldown
		):
			continue

		last_debug_collider = collider_node
		last_debug_time = current_time

		print("")
		print("########################################")
		print("        IMPORTANT PHYSICS HIT")
		print("########################################")

		print(
			"LANE: ",
			cur_pos
		)

		print(
			"TARGET X: ",
			lane_target_x
		)

		print(
			"X BEFORE PHYSICS: ",
			x_before_physics
		)

		print(
			"X AFTER PHYSICS: ",
			x_after_physics
		)

		print(
			"X CHANGE: ",
			x_change
		)

		print(
			"COLLIDER: ",
			collider_node.name
		)

		print(
			"TYPE: ",
			collider_node.get_class()
		)

		print(
			"PATH: ",
			collider_node.get_path()
		)

		print(
			"GROUPS: ",
			collider_node.get_groups()
		)

		print(
			"NORMAL: ",
			normal
		)

		print(
			"COLLISION POINT: ",
			collision.get_position()
		)

		print(
			"COLLISION DEPTH: ",
			collision.get_depth()
		)

		print("########################################")

		break


# =========================================================
# RAYCAST DEBUG
# =========================================================

func _debug_raycast_hit(hit: Node) -> void:

	var current_time: float = (
		Time.get_ticks_msec() / 1000.0
	)

	if (
		hit == last_debug_collider
		and
		current_time - last_debug_time < debug_cooldown
	):
		return

	last_debug_collider = hit
	last_debug_time = current_time

	print("")
	print("========== RAYCAST HIT ==========")

	print(
		"LANE: ",
		cur_pos
	)

	print(
		"PLAYER X: ",
		position.x
	)

	print(
		"HIT: ",
		hit.name
	)

	print(
		"TYPE: ",
		hit.get_class()
	)

	print(
		"PATH: ",
		hit.get_path()
	)

	print(
		"GROUPS: ",
		hit.get_groups()
	)

	print("==================================")


# =========================================================
# CHECK OBSTACLE
# =========================================================

func _is_obstacle(hit: Node) -> bool:

	var current_node: Node = hit

	while current_node != null:

		if current_node.is_in_group("desk"):
			return true

		if current_node.is_in_group("fire"):
			return true

		if current_node.is_in_group("panel"):
			return true

		current_node = current_node.get_parent()

	return false


# =========================================================
# DIE
# =========================================================

func die() -> void:

	if is_dead:
		return

	is_dead = true


	# =====================================================
	# CHICKEN ATTACK
	# =====================================================

	_chicken_attack()


	# =====================================================
	# STOP PLAYER ANIMATIONS
	# =====================================================

	if anim_run:
		anim_run.stop()

	if anim_jump:
		anim_jump.stop()


	# =====================================================
	# STOP CHICKEN RUN
	# =====================================================

	if fast_run_anim:
		fast_run_anim.stop()


	# =====================================================
	# HIDE PLAYER RUN / JUMP
	# =====================================================

	if node_run:
		node_run.visible = false

	if node_jump:
		node_jump.visible = false


	# =====================================================
	# SHOW DIE
	# =====================================================

	if node_die:
		node_die.visible = true


	# =====================================================
	# DIE ANIMATION
	# =====================================================

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


	# =====================================================
	# GAME OVER
	# =====================================================

	Global.game_on = false

	velocity = Vector3.ZERO

	set_physics_process(false)


# =========================================================
# CHICKEN ATTACK
# =========================================================

func _chicken_attack() -> void:

	if chicken == null:
		return


	# =====================================================
	# STOP RUN
	# =====================================================

	if fast_run_anim:
		fast_run_anim.stop()


	# =====================================================
	# SWITCH MODEL
	# =====================================================

	if fast_run__1_:
		fast_run__1_.visible = false

	if jump_attack__1_:
		jump_attack__1_.visible = true


	# =====================================================
	# PLAY ATTACK
	# =====================================================

	if jump_attack_anim:

		var attack_anim_name = _get_first_anim_name(
			jump_attack_anim
		)

		if attack_anim_name != "":

			var attack_anim = jump_attack_anim.get_animation(
				attack_anim_name
			)

			if attack_anim:

				jump_attack_anim.speed_scale = 2.0

				jump_attack_anim.play(
					attack_anim_name
				)


				# =================================================
				# MOVE CHICKEN FORWARD
				# =================================================

				var start_z = chicken.position.z

				var target_z = start_z - 1.0

				var attack_time = attack_anim.length / 2.0

				var tween = create_tween()

				tween.tween_property(
					chicken,
					"position:z",
					target_z,
					attack_time
				).set_trans(
					Tween.TRANS_QUAD
				).set_ease(
					Tween.EASE_OUT
				)


# =========================================================
# GET FIRST ANIMATION
# =========================================================

func _get_first_anim_name(
	player_node: AnimationPlayer
) -> String:

	if player_node:

		var anim_list = player_node.get_animation_list()

		if anim_list.size() > 0:

			return anim_list[0]

	return ""


# =========================================================
# PLAY PLAYER ANIMATION
# =========================================================

func _play_animation(
	target_anim: AnimationPlayer,
	active_node: Node3D
) -> void:

	# =====================================================
	# STOP ALL
	# =====================================================

	if anim_run:
		anim_run.stop()

	if anim_jump:
		anim_jump.stop()

	if anim_die:
		anim_die.stop()


	# =====================================================
	# HIDE ALL MODELS
	# =====================================================

	if node_run:
		node_run.visible = false

	if node_jump:
		node_jump.visible = false

	if node_die:
		node_die.visible = false


	# =====================================================
	# SHOW ACTIVE MODEL
	# =====================================================

	if active_node:
		active_node.visible = true


	# =====================================================
	# PLAY ANIMATION
	# =====================================================

	if target_anim:

		var anim_name = _get_first_anim_name(
			target_anim
		)

		if anim_name != "":

			# =============================================
			# RUN ANIMATION = DEPENDS ON GAME SPEED
			# =============================================

			if target_anim == anim_run:

				var speed_ratio: float = clamp(
					Global.game_speed / Global.max_game_speed,
					0.0,
					1.0
				)

				target_anim.speed_scale = lerpf(
					min_run_anim_speed,
					max_run_anim_speed,
					speed_ratio
				)

			else:

				target_anim.speed_scale = 1.0


			target_anim.play(
				anim_name,
				0.1
			)


# =========================================================
# JUMP FINISHED
# =========================================================

func _on_jump_finished(
	_anim_name: StringName
) -> void:

	if not is_on_floor():
		return

	if is_dead:
		return

	is_jumping = false


	# =====================================================
	# CHICKEN RUN AGAIN
	# =====================================================

	if fast_run_anim:

		var chicken_run_name = _get_first_anim_name(
			fast_run_anim
		)

		if chicken_run_name != "":

			fast_run_anim.speed_scale = 1.0
			fast_run_anim.play(chicken_run_name)


	# =====================================================
	# PLAYER RUN AGAIN
	# =====================================================

	_play_animation(
		anim_run,
		node_run
	)
