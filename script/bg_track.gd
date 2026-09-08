extends AudioStreamPlayer


# =========================
# SETTINGS
# =========================

@export var fade_duration: float = 2.0

var fade_tween: Tween


# =========================
# READY
# =========================

func _ready() -> void:

	# Start completely silent
	volume_db = -80.0

	# Play music
	play()

	# Fade in
	fade_tween = create_tween()

	fade_tween.tween_property(
		self,
		"volume_db",
		-24.0,
		fade_duration
	)
