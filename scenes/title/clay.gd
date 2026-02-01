extends Node2D

@export var animated_sprite: AnimatedSprite2D
@export var bob_height: float = 10.0
@export var bob_duration: float = 1.5

func _ready() -> void:
	_start_bob()

func _start_bob() -> void:
	var base_y := animated_sprite.position.y
	var tween := create_tween().set_loops()
	tween.tween_property(animated_sprite, "position:y", base_y - bob_height, bob_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(animated_sprite, "position:y", base_y, bob_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
