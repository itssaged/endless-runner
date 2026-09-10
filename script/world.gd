extends Node3D

@onready var coin_label: Label = $CanvasLayer/UI/Panel/Label
@onready var score_label: Label = $CanvasLayer/UI/Panel2/Label
@onready var control: Control = $CanvasLayer/Control
@onready var ui: Control = $CanvasLayer/UI
@onready var label_3: Label = $CanvasLayer/Control/Panel/Label3
@onready var high_score_label: Label = $CanvasLayer/Control/Panel/highest_score

@onready var mute: Button = $CanvasLayer/mute
@onready var unmute: Button = $CanvasLayer/unmute

@onready var bg_track: AudioStreamPlayer = $"BG TRACK"

var score: int = 0

var score_glow: bool = false
var glow_time: float = 0.0

func _ready() -> void:
	high_score_label.text = str(Global.high_score)
	mute.visible = true
	unmute.visible = false

	score_label.modulate = Color.WHITE

func _physics_process(delta: float) -> void:

	coin_label.text = str(Global.coins)
	high_score_label.text = str(Global.high_score)
	if Global.game_on:

		score += 1
		score_label.text = str(score)

		if Global.high_score > 0:

			if score > Global.high_score:

				Global.high_score = score

				if not score_glow:

					score_glow = true
					glow_time = 0.0

	if score_glow:

		glow_time += delta

		var pulse: float = (sin(glow_time * 6.0) + 1.0) / 2.0

		var brightness: float = lerp(1.0, 1.5, pulse)

		score_label.modulate = Color(
			brightness,
			brightness * 0.75,
			0.1,
			1.0
		)

func _on_player_player_died() -> void:

	$CanvasLayer/Control/AudioStreamPlayer3D.play()

	ui.visible = false
	control.visible = true

	label_3.text = str(score)

	if score > Global.high_score:

		Global.high_score = score

func _on_button_pressed() -> void:

	Global.game_on = true
	Global.coins = 0
	Global.game_time = 0.0
	Global.game_speed = 0.0

	score = 0

	score_glow = false
	glow_time = 0.0

	score_label.modulate = Color.WHITE

	get_tree().reload_current_scene()

func _on_button_2_pressed() -> void:

	get_tree().quit()

func _on_mute_pressed() -> void:

	if bg_track:
		bg_track.stop()

	mute.visible = false
	unmute.visible = true

func _on_unmute_pressed() -> void:

	if bg_track:
		bg_track.play()

	mute.visible = true
	unmute.visible = false
