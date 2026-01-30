extends TextureRect

var tween: Tween

func _ready():
	pivot_offset = texture.get_size() / 4
	
	tween = create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(self, "rotation_degrees", 4, 2.0)
	tween.tween_property(self, "rotation_degrees", -4, 2.0)
	
func _on_mouse_entered() -> void:
	var hover_tween = create_tween().set_ease(Tween.EASE_OUT)
	hover_tween.set_trans(Tween.TRANS_LINEAR)
	hover_tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.25)

func _on_mouse_exited() -> void:
	var hover_tween = create_tween().set_ease(Tween.EASE_OUT)
	hover_tween.set_trans(Tween.TRANS_LINEAR)
	hover_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.25)
	
# Exaggerate the logo when an option is selected
func _on_title_button_pressed() -> void:
	var click_tween = create_tween().set_ease(Tween.EASE_OUT)
	click_tween.set_trans(Tween.TRANS_ELASTIC)
	click_tween.tween_property(self, "scale", Vector2(1.3, 1.3), 0.2)
