extends AudioStreamPlayer

@export var fade_duration: float = 2.0

var fade_tween: Tween

func _ready() -> void:

	volume_db = -80.0

	play()

	fade_tween = create_tween()

	fade_tween.tween_property(
		self,
		"volume_db",
		-24.0,
		fade_duration
	)
