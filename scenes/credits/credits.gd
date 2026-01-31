extends Control

var element_tween: Tween
var hovered_element: Control
var hovered_element_scale: Vector2
var hovered_element_position: Vector2

func _ready() -> void:
	GameManager.escape_pressed.connect(_on_exit_pressed)

func _on_mouse_enter() -> void:
	hovered_element = get_viewport().gui_get_hovered_control()
	hovered_element.pivot_offset = hovered_element.size / 2
	hovered_element_scale = hovered_element.scale
	hovered_element_position = hovered_element.position
	print("1", hovered_element_position,hovered_element.position)
	element_tween = create_tween().set_ease(Tween.EASE_OUT)
	element_tween.set_trans(Tween.TRANS_ELASTIC)
	element_tween.tween_property(hovered_element, "scale", Vector2(hovered_element_scale.x * 1.15, hovered_element_scale.y * 1.15), 0.25)
	
func _on_mouse_leave() -> void:
	if element_tween: element_tween.kill()
	hovered_element.scale = hovered_element_scale
	hovered_element.position = hovered_element_position
	
func _on_exit_hovered() -> void:
	hovered_element = get_viewport().gui_get_hovered_control()
	hovered_element_scale = hovered_element.scale
	element_tween = create_tween().set_ease(Tween.EASE_OUT)
	element_tween.set_trans(Tween.TRANS_ELASTIC)
	element_tween.tween_property(hovered_element, "scale", Vector2(hovered_element_scale.x * 1.15, hovered_element_scale.y * 1.15), 0.25)

func _on_exit_unhovered() -> void:
	if element_tween: element_tween.kill()
	hovered_element.scale = hovered_element_scale

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title/title.tscn")
