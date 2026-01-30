extends Button

var tween: Tween

signal start_pressed
signal options_pressed
signal credits_pressed

func _ready() -> void:
	pivot_offset = size * Vector2(0.5, 1.0)
	
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_leave)
	
func _on_button_up() -> void:
	tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.25)

func _on_mouse_leave() -> void:
	if tween: tween.kill()
	scale = Vector2(1.0, 1.0)
	
func _on_mouse_enter() -> void:
	tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.25)
	
func _on_button_down() -> void:
	self.disabled = true
	pivot_offset = size / 2
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.4, 1.4), 0.2)
	tween.tween_property(self, "scale", Vector2(0, 0), 0.2)
	
	await tween.finished
	
	# Create a fade overlay
	var fade = ColorRect.new()
	fade.color = Color.BLACK
	fade.modulate.a = 0.0
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().current_scene.add_child(fade)
	
	# Fade to black
	var fade_tween = create_tween()
	fade_tween.tween_property(fade, "modulate:a", 1.0, 0.2).set_delay(0.4)
	
	_execute_on_click()

# TODO: Hook up these buttons
func _execute_on_click() -> void:
	if self.name == "Start":
		start_pressed.emit()
	elif self.name == "Options":
		options_pressed.emit()
	elif self.name == "Credits":
		credits_pressed.emit()
	
