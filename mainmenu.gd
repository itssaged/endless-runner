extends Node3D

# الدالة دي بتشتغل أول ما اللاعب يدوس على الزرار
func _on_button_pressed() -> void:
# دي بتنقلك لمشهد اللعبة الأساسي (تأكد إن مسار مشهدك صح)
	get_tree().change_scene_to_file("res://scenes/world.tscn")
