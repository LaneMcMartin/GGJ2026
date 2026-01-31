extends ColorRect

## Emitted when the close transition animation finishes (screen is fully covered).
signal transition_closed
## Emitted when the open transition animation finishes (screen is fully visible).
signal transition_opened

func _ready() -> void:
	GameManager.level_complete.connect(close_transition)

func close_transition() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(material, "shader_parameter/progress", 1.0, 0.3).from(0.0)
	tween.tween_callback(func(): transition_closed.emit())

func open_transition() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(material, "shader_parameter/progress", 0.0, 0.3).from(1.0)
	tween.tween_callback(func(): transition_opened.emit())
