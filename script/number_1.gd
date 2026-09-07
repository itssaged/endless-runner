extends Node3D


# =========================================================
# SCENES
# =========================================================

var desk_scene: PackedScene = preload("res://scenes/desk.tscn")
var coin_scene: PackedScene = preload("res://scenes/coin.tscn")


# =========================================================
# LANES
# =========================================================

@onready var left_point: Marker3D = $"Node2/lane one"
@onready var middle_point: Marker3D = $"Node2/lane two"
@onready var right_point: Marker3D = $"Node2/lane three"


# =========================================================
# CORRIDOR
# =========================================================

@export var corridor_length: float = 58.0


# =========================================================
# START DELAY
# =========================================================

@export var start_delay: float = 3.0

var elapsed_time: float = 0.0
var objects_generated: bool = false


# =========================================================
# DESK SETTINGS
# =========================================================

# المسافة الأساسية بين مجموعات الـdesks
@export var min_z_distance: float = 8.0

# أقل مسافة ممكنة
@export var minimum_desk_distance: float = 4.5


# =========================================================
# COINS
# =========================================================

@export var min_coins: int = 5
@export var max_coins: int = 13

@export var coin_spacing: float = 2.0

@export var min_coin_group_distance: float = 10.0
@export var max_coin_group_distance: float = 30.0

@export var desk_safe_distance: float = 3.0


# =========================================================
# SAVED DESK POSITIONS
# =========================================================

var desk_positions: Array[Dictionary] = []


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	randomize()


# =========================================================
# PROCESS
# =========================================================

func _process(delta: float) -> void:

	if not Global.game_on:
		return

	if not objects_generated:

		elapsed_time += delta

		if elapsed_time >= start_delay:

			objects_generated = true

			generate_desks()
			generate_coins()


	# =====================================================
	# MOVE CORRIDOR
	# =====================================================

	# السرعة تأتي من Global فقط
	#position.z -= Global.game_speed * delta


	# =====================================================
	# START DELAY
	# =====================================================

	if not objects_generated:

		elapsed_time += delta

		if elapsed_time >= start_delay:

			objects_generated = true

			generate_desks()
			generate_coins()


# =========================================================
# DESKS
# =========================================================

func generate_desks() -> void:

	var lanes: Array[Marker3D] = [
		left_point,
		middle_point,
		right_point
	]


	# =====================================================
	# CURRENT GAME TIME
	# =====================================================

	var game_time: float = Global.game_time


	# =====================================================
	# NUMBER OF DESK GROUPS
	# =====================================================

	var groups: int = 2


	if game_time >= 15.0:
		groups = 3

	if game_time >= 30.0:
		groups = 4

	if game_time >= 45.0:
		groups = 5

	if game_time >= 60.0:
		groups = 6

	if game_time >= 90.0:
		groups = 7


	# =====================================================
	# DISTANCE BETWEEN DESK GROUPS
	# =====================================================

	var current_min_distance: float = min_z_distance


	if game_time >= 15.0:
		current_min_distance = 5.0

	if game_time >= 30.0:
		current_min_distance = 4.0

	if game_time >= 45.0:
		current_min_distance = 3.5

	if game_time >= 60.0:
		current_min_distance = 3.0

	if game_time >= 90.0:
		current_min_distance = minimum_desk_distance


	current_min_distance = max(
		current_min_distance,
		minimum_desk_distance
	)


	# =====================================================
	# USED Z POSITIONS
	# =====================================================

	var used_z_positions: Array[float] = []

	var attempts: int = 0


	# =====================================================
	# GENERATE DESK GROUPS
	# =====================================================

	while used_z_positions.size() < groups and attempts < 1000:

		attempts += 1


		var chosen_z: float = randf_range(
			2.0,
			corridor_length - 2.0
		)


		var valid_z: bool = true


		# =================================================
		# CHECK DISTANCE
		# =================================================

		for used_z: float in used_z_positions:

			if abs(chosen_z - used_z) < current_min_distance:

				valid_z = false
				break


		if not valid_z:
			continue


		used_z_positions.append(chosen_z)


		# =================================================
		# NUMBER OF DESKS IN GROUP
		# =================================================

		var desk_amount: int = 1


		# البداية سهلة
		if game_time < 15.0:

			desk_amount = randi_range(1, 2)


		# بعد 15 ثانية
		elif game_time < 30.0:

			desk_amount = 2


		# بعد 30 ثانية
		elif game_time < 60.0:

			desk_amount = randi_range(1, 2)


		# بعد دقيقة
		elif game_time < 90.0:

			desk_amount = 2


		# بعد 90 ثانية
		else:

			desk_amount = randi_range(2, 3)


		# لا يمكن وضع أكثر من 3 desks
		desk_amount = clamp(
			desk_amount,
			1,
			3
		)


		# =================================================
		# SHUFFLE LANES
		# =================================================

		var shuffled_lanes: Array[Marker3D] = lanes.duplicate()

		shuffled_lanes.shuffle()


		# =================================================
		# SPAWN DESKS
		# =================================================

		for i: int in range(desk_amount):

			var point: Marker3D = shuffled_lanes[i]

			spawn_desk(
				point,
				chosen_z
			)


# =========================================================
# SPAWN DESK
# =========================================================

func spawn_desk(
	point: Marker3D,
	z_position: float
) -> void:

	var desk: Node3D = desk_scene.instantiate() as Node3D


	var marker_pos: Vector3 = to_local(
		point.global_position
	)


	desk.position = Vector3(
		marker_pos.x,
		marker_pos.y,
		z_position
	)


	add_child(desk)


	# =====================================================
	# SAVE DESK POSITION
	# =====================================================

	desk_positions.append({
		"x": marker_pos.x,
		"z": z_position
	})


# =========================================================
# COINS
# =========================================================

func generate_coins() -> void:

	var lanes: Array[Marker3D] = [
		left_point,
		middle_point,
		right_point
	]


	var current_z: float = 0.0

	var groups: int = randi_range(1, 3)


	for group_index: int in range(groups):

		var coin_count: int = randi_range(
			min_coins,
			max_coins
		)


		var group_length: float = (
			(coin_count - 1) * coin_spacing
		)


		if current_z + group_length > corridor_length:

			break


		# =================================================
		# RANDOM LANE
		# =================================================

		var shuffled_lanes: Array[Marker3D] = lanes.duplicate()

		shuffled_lanes.shuffle()


		var point: Marker3D = shuffled_lanes[0]


		# =================================================
		# SPAWN COINS
		# =================================================

		for i: int in range(coin_count):

			var coin_z: float = (
				current_z +
				(i * coin_spacing)
			)


			if not is_coin_position_blocked(
				point,
				coin_z
			):

				spawn_coin(
					point,
					coin_z
				)


		# =================================================
		# NEXT GROUP
		# =================================================

		var group_distance: float = randf_range(
			min_coin_group_distance,
			max_coin_group_distance
		)


		current_z += (
			group_length +
			group_distance
		)


# =========================================================
# SPAWN COIN
# =========================================================

func spawn_coin(
	point: Marker3D,
	z_position: float
) -> void:

	var coin: Node3D = coin_scene.instantiate() as Node3D


	var marker_pos: Vector3 = to_local(
		point.global_position
	)


	coin.position = Vector3(
		marker_pos.x,
		marker_pos.y,
		z_position
	)


	add_child(coin)


# =========================================================
# CHECK COIN / DESK
# =========================================================

func is_coin_position_blocked(
	coin_lane: Marker3D,
	coin_z: float
) -> bool:

	var coin_pos: Vector3 = to_local(
		coin_lane.global_position
	)


	var coin_x: float = coin_pos.x


	# =====================================================
	# CHECK ALL DESKS
	# =====================================================

	for desk_data: Dictionary in desk_positions:

		var desk_x: float = float(
			desk_data["x"]
		)


		var desk_z: float = float(
			desk_data["z"]
		)


		var x_distance: float = abs(
			desk_x - coin_x
		)


		var z_distance: float = abs(
			desk_z - coin_z
		)


		if (
			x_distance < 1.0
			and
			z_distance < desk_safe_distance
		):

			return true


	return false
