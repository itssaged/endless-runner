extends Node


var coins: int = 0
var game_on: bool = true


# =========================================================
# DIFFICULTY
# =========================================================

var game_time: float = 0.0

# سرعة البداية
var game_speed: float = 20.0

# أقصى سرعة
var max_game_speed: float = 60.0

# زيادة السرعة كل ثانية
var speed_increase: float = 0.3


# =========================================================
# PROCESS
# =========================================================

func _process(delta: float) -> void:

	if not game_on:
		return

	game_time += delta

	game_speed = min(
		20.0 + (game_time * speed_increase),
		max_game_speed
	)
