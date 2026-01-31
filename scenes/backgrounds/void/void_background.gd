## Very simple script to make the BG elements bob up and down.
extends Control

@export var bg_l_1: Sprite2D
@export var bg_l_2: Sprite2D
@export var bg_l_3: Sprite2D

func _ready() -> void:
	_start_bob(bg_l_1, 8.0, 2.0)
	_start_bob(bg_l_2, 10.0, 2.4)
	_start_bob(bg_l_3, 6.0, 1.8)

func _start_bob(sprite: Sprite2D, amplitude: float, duration: float) -> void:
	var start_y := sprite.position.y
	var tween := create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "position:y", start_y + amplitude, duration)
	tween.tween_property(sprite, "position:y", start_y, duration)
