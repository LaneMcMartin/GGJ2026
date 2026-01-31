extends ColorRect

func _ready() -> void:
	GameManager.level_complete.connect(close_transition)
	GameManager.level_start.connect(open_transition)
	
func close_transition() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(material, "shader_parameter/progress", 1.0, 0.3).from(0.0)

func open_transition() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(material, "shader_parameter/progress", 0.0, 0.3).from(1.0)
