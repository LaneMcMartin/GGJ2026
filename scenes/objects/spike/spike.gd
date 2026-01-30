extends Node

@export var sprite_2d: Sprite2D

const FRAME_POSITIONS := [0, 64, 128]
const CYCLE_TIME := 0.5

var current_frame := 0
var timer := 0.0

func _ready() -> void:
	sprite_2d.region_enabled = true
	# Each instance starts at a different frame
	current_frame = randi() % FRAME_POSITIONS.size()
	_update_region()
	
func _process(delta: float) -> void:
	timer += delta
	if timer >= CYCLE_TIME:
		timer -= CYCLE_TIME
		current_frame = (current_frame + 1) % FRAME_POSITIONS.size()
		_update_region()

func _update_region() -> void:
	sprite_2d.region_rect.position.x = FRAME_POSITIONS[current_frame]

func on_body_entered(body: Node2D) -> void:
	if body is Player:
		body._player_died()
