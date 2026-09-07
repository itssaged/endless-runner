extends Node3D

@onready var coin_label: Label = $CanvasLayer/UI/Panel/Label
@onready var score_label: Label = $CanvasLayer/UI/Panel2/Label
@onready var control: Control = $CanvasLayer/Control
@onready var ui: Control = $CanvasLayer/UI
@onready var label_3: Label = $CanvasLayer/Control/Panel/Label3

var score: int = 0


func _physics_process(_delta: float) -> void:
	coin_label.text = str(Global.coins)

	if Global.game_on:
		score += 1
		score_label.text = str(score)


func _on_player_player_died() -> void:
	$CanvasLayer/Control/AudioStreamPlayer3D.play()

	ui.visible = false
	control.visible = true
	label_3.text = str(score)


func _on_button_pressed() -> void:
	# Reset game state
	Global.game_on = true
	Global.coins = 0
	Global.game_time = 0.0
	Global.game_speed = 20.0

	# Reload level
	get_tree().reload_current_scene()


func _on_button_2_pressed() -> void:
	get_tree().quit()
