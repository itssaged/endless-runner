extends Node


# =========================================================
# GAME DATA
# =========================================================

var coins: int = 0

var score: int = 0
var high_score: int = 0

# الـ High Score اللي كان موجود قبل بداية الـ Run الحالي
var run_start_high_score: int = 0

# True لما اللاعب يكسر الـ High Score في الـ Run الحالي
var is_new_high_score: bool = false

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
# READY
# =========================================================

func _ready() -> void:
	load_high_score()


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


# =========================================================
# SCORE
# =========================================================

func reset_run() -> void:

	score = 0

	game_time = 0.0

	game_speed = 20.0

	game_on = true

	is_new_high_score = false

	# نحفظ الرقم القديم قبل بداية الـ Run
	run_start_high_score = high_score


func add_score(amount: int) -> void:

	score += amount

	# اللاعب كسر الـ High Score القديم
	if score > run_start_high_score:
		is_new_high_score = true

	# تحديث الـ High Score الحقيقي
	if score > high_score:
		high_score = score
		save_high_score()


# =========================================================
# HIGH SCORE SAVE
# =========================================================

func save_high_score() -> void:

	var file := FileAccess.open(
		"user://highscore.save",
		FileAccess.WRITE
	)

	if file:
		file.store_32(high_score)


# =========================================================
# HIGH SCORE LOAD
# =========================================================

func load_high_score() -> void:

	if not FileAccess.file_exists("user://highscore.save"):
		high_score = 0
		return

	var file := FileAccess.open(
		"user://highscore.save",
		FileAccess.READ
	)

	if file:
		high_score = file.get_32()
