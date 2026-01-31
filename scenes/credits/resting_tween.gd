extends TextureRect

var resting_element_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pivot_offset = self.get_size() / 4
	
	resting_element_tween = create_tween()
	resting_element_tween.set_loops()
	resting_element_tween.set_trans(Tween.TRANS_SINE)
	resting_element_tween.set_ease(Tween.EASE_IN_OUT)
	
	resting_element_tween.tween_property(self, "rotation_degrees", 4, 2.0)
	resting_element_tween.tween_property(self, "rotation_degrees", -4, 2.0)
