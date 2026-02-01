## Very simple script to make the BG elements bob up and down.
extends Control

@export var bg_l_1: Sprite2D
@export var bg_l_2: Sprite2D
@export var bg_l_3: Sprite2D

# Easter egg...
const BACKGROUND_L_1 = preload("uid://16k3bev4ogil")
const EGG = preload("uid://5n6j1cvsy1vt")

func _ready() -> void:
	_start_bob(bg_l_1, 8.0, 2.0)
	_start_bob(bg_l_2, 10.0, 2.4)
	_start_bob(bg_l_3, 6.0, 1.8)
	GameManager.level_start.connect(_roll_egg)
	
func _roll_egg() -> void:
	# Roll for egg.
	var chance: int = randi_range(0, 50)
	if (chance == 13):
		bg_l_1.texture = EGG
	else:
		bg_l_1.texture = BACKGROUND_L_1

func _start_bob(sprite: Sprite2D, amplitude: float, duration: float) -> void:
	var start_y := sprite.position.y
	var tween := create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "position:y", start_y + amplitude, duration)
	tween.tween_property(sprite, "position:y", start_y, duration)
