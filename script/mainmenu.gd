extends Node3D

func _on_button_pressed() -> void:
	Global.reset_run()
	Global.game_time = 0.0
	Global.game_speed = 20.0
	Global.game_on = true
	Global.coins = 0

	get_tree().change_scene_to_file(
		"res://scenes/world.tscn"
	)

@onready var secret_sound: AudioStreamPlayer = $"CanvasLayer/floppa and chicken/Button2/AudioStreamPlayer"

func _on_button_2_pressed() -> void:
	if secret_sound:
		secret_sound.play()

@onready var dancing_twerk: Node3D = $"Dancing Twerk"
@onready var twist_dance: Node3D = $"Twist Dance"
@onready var thriller_part_2: Node3D = $"Thriller Part 2"
@onready var samba_dancing: Node3D = $"Samba Dancing"
@onready var breakdance_freeze_var_2: Node3D = $"Breakdance Freeze Var 2"
@onready var dancing: Node3D = $Dancing
@onready var snake_hip_hop_dance: Node3D = $"Snake Hip Hop Dance"
@onready var swing_dancing: Node3D = $"Swing Dancing"
@onready var bellydancing: Node3D = $Bellydancing
@onready var dancingg: Node3D = $"Dancing (1)"

@onready var dancing_twerk_anim: AnimationPlayer = $"Dancing Twerk/AnimationPlayer2"
@onready var twist_dance_anim: AnimationPlayer = $"Twist Dance/AnimationPlayer2"
@onready var thriller_part_2_anim: AnimationPlayer = $"Thriller Part 2/AnimationPlayer2"
@onready var samba_dancing_anim: AnimationPlayer = $"Samba Dancing/AnimationPlayer2"
@onready var breakdance_freeze_var_2_anim: AnimationPlayer = $"Breakdance Freeze Var 2/AnimationPlayer2"
@onready var dancing_anim: AnimationPlayer = $"Dancing/AnimationPlayer2"
@onready var snake_hip_hop_dance_anim: AnimationPlayer = $"Snake Hip Hop Dance/AnimationPlayer2"
@onready var swing_dancing_anim: AnimationPlayer = $"Swing Dancing/AnimationPlayer2"
@onready var bellydance_anim: AnimationPlayer = $"Bellydancing/AnimationPlayer2"
@onready var dancingg_anim: AnimationPlayer = $"Dancing (1)/AnimationPlayer2"

@onready var menu_audio: AudioStreamPlayer = $AudioStreamPlayer

var dance_songs: Array = [
	preload("res://assets/sounds/مهرجان - سهران ليلاتي - ميسو ميسره - عمر id - مؤمن الجحيم - توزيع زيكو العالمي - مهرجانات 2024 (mp3cut.net).mp3"),
	preload("res://assets/sounds/ياعايقه يا رايقه.mp3"),
	preload("res://assets/sounds/اطبطب وادلع.mp3"),
	preload("res://assets/sounds/العوده من بعد الغياب.mp3"),
	preload("res://assets/sounds/عليكي بكراش.mp3"),
	preload("res://assets/sounds/شخبط شخابيط.mp3"),
	preload("res://assets/sounds/aghny-azaz-kaborya-.mp3"),
	preload("res://assets/sounds/nancy-ajram-ma-tegi-hena-official-music-video_yCY8T0qT.mp3"),
	preload("res://assets/sounds/ali ya ali .mp3"),
	preload("res://assets/sounds/last song.mp3")
]

var current_dance: int = 0

func _ready() -> void:
	_set_dance(0)

func _on_button_3_pressed() -> void:
	current_dance += 1

	if current_dance > 9:
		current_dance = 0

	_set_dance(current_dance)

func _set_dance(index: int) -> void:

	if dancing_twerk:
		dancing_twerk.visible = false

	if twist_dance:
		twist_dance.visible = false

	if thriller_part_2:
		thriller_part_2.visible = false

	if samba_dancing:
		samba_dancing.visible = false

	if breakdance_freeze_var_2:
		breakdance_freeze_var_2.visible = false

	if dancing:
		dancing.visible = false

	if snake_hip_hop_dance:
		snake_hip_hop_dance.visible = false

	if swing_dancing:
		swing_dancing.visible = false

	if bellydancing:
		bellydancing.visible = false

	if dancingg:
		dancingg.visible = false

	if dancing_twerk_anim:
		dancing_twerk_anim.stop()

	if twist_dance_anim:
		twist_dance_anim.stop()

	if thriller_part_2_anim:
		thriller_part_2_anim.stop()

	if samba_dancing_anim:
		samba_dancing_anim.stop()

	if breakdance_freeze_var_2_anim:
		breakdance_freeze_var_2_anim.stop()

	if dancing_anim:
		dancing_anim.stop()

	if snake_hip_hop_dance_anim:
		snake_hip_hop_dance_anim.stop()

	if swing_dancing_anim:
		swing_dancing_anim.stop()

	if bellydance_anim:
		bellydance_anim.stop()

	if dancingg_anim:
		dancingg_anim.stop()

	match index:

		0:
			dancing_twerk.visible = true
			_play_animation(dancing_twerk_anim)

		1:
			twist_dance.visible = true
			_play_animation(twist_dance_anim)

		2:
			thriller_part_2.visible = true
			_play_animation(thriller_part_2_anim)

		3:
			samba_dancing.visible = true
			_play_animation(samba_dancing_anim)

		4:
			breakdance_freeze_var_2.visible = true
			_play_animation(breakdance_freeze_var_2_anim)

		5:
			dancing.visible = true
			_play_animation(dancing_anim)

		6:
			snake_hip_hop_dance.visible = true
			_play_animation(snake_hip_hop_dance_anim)

		7:
			swing_dancing.visible = true
			_play_animation(swing_dancing_anim)

		8:
			bellydancing.visible = true
			_play_animation(bellydance_anim)

		9:
			dancingg.visible = true
			_play_animation(dancingg_anim)

	if menu_audio and dance_songs.size() > 0:

		var song_index = index % dance_songs.size()

		menu_audio.stream = dance_songs[song_index]

		if song_index == 0:
			menu_audio.volume_db = -20.0
		elif song_index==2:
			menu_audio.volume_db = -12.0
		else:
			menu_audio.volume_db = -20.0

		menu_audio.play()

func _get_first_anim_name(
	player_node: AnimationPlayer
) -> String:

	if player_node:

		var anim_list = player_node.get_animation_list()

		if anim_list.size() > 0:
			return anim_list[0]

	return ""

func _play_animation(
	target_anim: AnimationPlayer
) -> void:

	if target_anim == null:
		return

	var anim_name = _get_first_anim_name(
		target_anim
	)

	if anim_name != "":

		var anim = target_anim.get_animation(
			anim_name
		)

		if anim:
			anim.loop_mode = Animation.LOOP_LINEAR

		target_anim.speed_scale = 1.0

		target_anim.play(
			anim_name,
			0.1
		)
