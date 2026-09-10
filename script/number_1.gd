extends Node3D

var desk_scene: PackedScene = preload("res://scenes/desk.tscn")
var fire_extinguisher_scene: PackedScene = preload("res://scenes/fire_extinguisher.tscn")
var panel2_scene: PackedScene = preload("res://scenes/panel_2.tscn")
var coin_scene: PackedScene = preload("res://scenes/coin.tscn")

@onready var left_point: Marker3D = $"Node2/lane one"
@onready var middle_point: Marker3D = $"Node2/lane two"
@onready var right_point: Marker3D = $"Node2/lane three"

@export var corridor_length: float = 58.0

@export var no_spawn_until_global_z: float = 100.0

@export var min_z_distance: float = 8.0
@export var minimum_desk_distance: float = 4.0

@export_range(0.0, 1.0)
var fire_extinguisher_chance: float = 0.3

@export_range(0.0, 1.0)
var panel2_chance: float = 0.2

@export var min_coins: int = 5
@export var max_coins: int = 13

@export var coin_spacing: float = 2.0

@export var min_coin_group_distance: float = 10.0
@export var max_coin_group_distance: float = 30.0

@export var desk_safe_distance: float = 3.0

var desk_positions: Array[Dictionary] = []

func _ready() -> void:

	randomize()

	generate_desks()
	generate_coins()

func _process(_delta: float) -> void:

	if not Global.game_on:
		return

func is_spawn_allowed(local_position: Vector3) -> bool:

	var global_position_of_object: Vector3 = to_global(
		local_position
	)

	return global_position_of_object.z >= no_spawn_until_global_z

func generate_desks() -> void:

	var lanes: Array[Marker3D] = [
		left_point,
		middle_point,
		right_point
	]

	var game_time: float = Global.game_time

	var groups: int = 2

	if game_time >= 15.0:
		groups = 3

	if game_time >= 30.0:
		groups = 3

	if game_time >= 45.0:
		groups = 4

	if game_time >= 60.0:
		groups = 4

	if game_time >= 90.0:
		groups = 4

	var current_min_distance: float = min_z_distance

	if game_time >= 15.0:
		current_min_distance = 7.0

	if game_time >= 30.0:
		current_min_distance = 6.0

	if game_time >= 45.0:
		current_min_distance = 5.0

	if game_time >= 60.0:
		current_min_distance = 5.0

	if game_time >= 90.0:
		current_min_distance = minimum_desk_distance

	current_min_distance = max(
		current_min_distance,
		minimum_desk_distance
	)

	var used_z_positions: Array[float] = []

	var attempts: int = 0

	while used_z_positions.size() < groups and attempts < 1000:

		attempts += 1

		var chosen_z: float = randf_range(
			2.0,
			corridor_length - 2.0
		)

		var valid_z: bool = true

		for used_z: float in used_z_positions:

			if abs(chosen_z - used_z) < current_min_distance:

				valid_z = false
				break

		if not valid_z:
			continue

		var test_local_position: Vector3 = Vector3(
			0.0,
			0.0,
			chosen_z
		)

		if not is_spawn_allowed(test_local_position):

			continue

		used_z_positions.append(chosen_z)

		var obstacle_amount: int = 1

		if game_time < 15.0:

			obstacle_amount = randi_range(1, 2)

		elif game_time < 30.0:

			obstacle_amount = 2

		elif game_time < 60.0:

			obstacle_amount = randi_range(1, 2)

		elif game_time < 90.0:

			obstacle_amount = 2

		else:

			obstacle_amount = randi_range(2, 3)

		obstacle_amount = clamp(
			obstacle_amount,
			1,
			3
		)

		var shuffled_lanes: Array[Marker3D] = lanes.duplicate()

		shuffled_lanes.shuffle()

		for i: int in range(obstacle_amount):

			var point: Marker3D = shuffled_lanes[i]

			var random_obstacle: float = randf()

			if random_obstacle < panel2_chance:

				spawn_panel2(
					point,
					chosen_z
				)

			elif random_obstacle < (
				panel2_chance
				+
				fire_extinguisher_chance
			):

				spawn_fire_extinguisher(
					point,
					chosen_z
				)

			else:

				spawn_desk(
					point,
					chosen_z
				)

func spawn_desk(
	point: Marker3D,
	z_position: float
) -> void:

	var marker_pos: Vector3 = to_local(
		point.global_position
	)

	var local_spawn_position: Vector3 = Vector3(
		marker_pos.x,
		marker_pos.y,
		z_position
	)

	if not is_spawn_allowed(local_spawn_position):

		return

	var desk: Node3D = desk_scene.instantiate() as Node3D

	desk.position = local_spawn_position

	add_child(desk)

	desk_positions.append({
		"x": marker_pos.x,
		"z": z_position
	})

func spawn_fire_extinguisher(
	point: Marker3D,
	z_position: float
) -> void:

	var marker_pos: Vector3 = to_local(
		point.global_position
	)

	var local_spawn_position: Vector3 = Vector3(
		marker_pos.x,
		marker_pos.y,
		z_position
	)

	if not is_spawn_allowed(local_spawn_position):

		return

	var fire_extinguisher: Node3D = (
		fire_extinguisher_scene.instantiate()
		as Node3D
	)

	fire_extinguisher.position = local_spawn_position

	add_child(fire_extinguisher)

	desk_positions.append({
		"x": marker_pos.x,
		"z": z_position
	})

func spawn_panel2(
	point: Marker3D,
	z_position: float
) -> void:

	var marker_pos: Vector3 = to_local(
		point.global_position
	)

	var local_spawn_position: Vector3 = Vector3(
		marker_pos.x,
		marker_pos.y,
		z_position
	)

	if not is_spawn_allowed(local_spawn_position):

		return

	var panel2: Node3D = (
		panel2_scene.instantiate()
		as Node3D
	)

	panel2.position = local_spawn_position

	add_child(panel2)

	desk_positions.append({
		"x": marker_pos.x,
		"z": z_position
	})

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

		var shuffled_lanes: Array[Marker3D] = lanes.duplicate()

		shuffled_lanes.shuffle()

		var point: Marker3D = shuffled_lanes[0]

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

		var group_distance: float = randf_range(
			min_coin_group_distance,
			max_coin_group_distance
		)

		current_z += (
			group_length +
			group_distance
		)

func spawn_coin(
	point: Marker3D,
	z_position: float
) -> void:

	var marker_pos: Vector3 = to_local(
		point.global_position
	)

	var local_spawn_position: Vector3 = Vector3(
		marker_pos.x,
		marker_pos.y,
		z_position
	)

	if not is_spawn_allowed(local_spawn_position):

		return

	var coin: Node3D = coin_scene.instantiate() as Node3D

	coin.position = local_spawn_position

	add_child(coin)

func is_coin_position_blocked(
	coin_lane: Marker3D,
	coin_z: float
) -> bool:

	var coin_pos: Vector3 = to_local(
		coin_lane.global_position
	)

	var coin_x: float = coin_pos.x

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
