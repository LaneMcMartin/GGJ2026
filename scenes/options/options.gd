extends Control

var element_tween: Tween
var hovered_element: Control

@export var show_unpause_button: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Pause menu
	#if show_unpause_button:
		#GameManager.escape_pressed.connect(_unpause)
	## Options screen
	#else:
		#GameManager.escape_pressed.connect(_exit_to_title)
		
	find_child("Unpause").visible = show_unpause_button
	if !show_unpause_button:
		get_node("MarginContainer").add_theme_constant_override("margin_top", 350)

func _exit_to_title() -> void:
	if get_tree().paused: get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/title/title.tscn")
	
func _unpause() -> void:		
	get_tree().paused = false
	queue_free()

func _on_music_volume_slider_value_changed(value: float) -> void:
	SoundManager.set_music_volume(value)

func _on_sfx_volume_slider_value_changed(value: float) -> void:
	SoundManager.set_sound_volume(value)

func _on_mouse_enter() -> void:
	hovered_element = get_viewport().gui_get_hovered_control()
	hovered_element.pivot_offset = hovered_element.size / 2
	element_tween = create_tween().set_ease(Tween.EASE_OUT)
	element_tween.set_trans(Tween.TRANS_ELASTIC)
	element_tween.tween_property(hovered_element, "scale", Vector2(1.15, 1.15), 0.25)
	
func _on_mouse_leave() -> void:
	if element_tween: element_tween.kill()
	hovered_element.scale = Vector2(1.0, 1.0)
	
func _input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key and key.pressed and not key.echo:
		if key.keycode == KEY_ESCAPE:
			get_viewport().set_input_as_handled() 
			if show_unpause_button:
				_unpause()
			# Options screen
			else:
				_exit_to_title()
