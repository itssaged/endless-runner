extends Node3D

var corridor: PackedScene = preload(
	"res://scenes/modules/number_1.tscn"
)

@export var offset: float = 58.0

@export var spawn_ahead: float = 300.0

@export var delete_behind: float = 70.0

var next_spawn_z: float = 0.0

func _ready() -> void:

	var player = get_tree().get_first_node_in_group("player")

	if player == null:

		push_error("Player not found!")

		return

	next_spawn_z = player.global_position.z

	while next_spawn_z < player.global_position.z + spawn_ahead:

		spawn_corridor(next_spawn_z)

		next_spawn_z += offset

func _process(delta: float) -> void:

	if not Global.game_on:
		return

	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		return

	for child in get_children():

		if child is Node3D:

			child.position.z -= (
				Global.game_speed * delta
			)

	next_spawn_z -= (
		Global.game_speed * delta
	)

	while next_spawn_z < player.global_position.z + spawn_ahead:

		spawn_corridor(next_spawn_z)

		next_spawn_z += offset

	for child in get_children():

		if child is Node3D:

			if child.global_position.z < (
				player.global_position.z
				-
				delete_behind
			):

				child.queue_free()

func spawn_corridor(z_position: float) -> void:

	var instance := corridor.instantiate() as Node3D

	if instance == null:

		push_error(
			"Failed to instantiate corridor!"
		)

		return

	instance.position = Vector3(
		0.0,
		0.0,
		z_position
	)

	add_child(instance)
