extends Node3D


# =========================================================
# CORRIDOR
# =========================================================

var corridor: PackedScene = preload(
	"res://scenes/modules/number_1.tscn"
)


# =========================================================
# SETTINGS
# =========================================================

# طول الـ corridor الواحد
@export var offset: float = 58.0

# كام متر نعمل Spawn قدام اللاعب
@export var spawn_ahead: float = 300.0

# امسح الـ corridors اللي ورا اللاعب بمسافة
@export var delete_behind: float = 70.0


# =========================================================
# SPAWN POSITION
# =========================================================

var next_spawn_z: float = 0.0


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	var player = get_tree().get_first_node_in_group("player")

	if player == null:

		push_error("Player not found!")

		return


	# =====================================================
	# START
	# =====================================================

	next_spawn_z = player.global_position.z


	# =====================================================
	# INITIAL CORRIDORS
	# =====================================================

	while next_spawn_z < player.global_position.z + spawn_ahead:

		spawn_corridor(next_spawn_z)

		next_spawn_z += offset


# =========================================================
# PROCESS
# =========================================================

func _process(delta: float) -> void:

	if not Global.game_on:
		return


	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		return


	# =====================================================
	# MOVE ALL CORRIDORS
	# =====================================================

	for child in get_children():

		if child is Node3D:

			child.position.z -= (
				Global.game_speed * delta
			)


	# =====================================================
	# MOVE VIRTUAL SPAWN POSITION
	# =====================================================

	next_spawn_z -= (
		Global.game_speed * delta
	)


	# =====================================================
	# SPAWN NEW CORRIDORS
	# =====================================================

	while next_spawn_z < player.global_position.z + spawn_ahead:

		spawn_corridor(next_spawn_z)

		next_spawn_z += offset


	# =====================================================
	# DELETE OLD CORRIDORS
	# =====================================================

	for child in get_children():

		if child is Node3D:

			if child.global_position.z < (
				player.global_position.z
				-
				delete_behind
			):

				child.queue_free()


# =========================================================
# SPAWN CORRIDOR
# =========================================================

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
