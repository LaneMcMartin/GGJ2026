extends Node

@export var sprite_2d: Sprite2D

const FRAME_POSITIONS := [0, 64, 128]
const CYCLE_TIME := 0.5

var current_frame := 0
var timer := 0.0
var _is_enabled: bool = true

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
	if _is_enabled and body is Player:
		body._player_died()

## Called by parent Keygroup when this spike is toggled.
func _on_keygroup_toggled(state: bool) -> void:
	_is_enabled = state
	
	# Disable all collision shapes on parent (the CharacterBody2D)
	var parent = get_parent()
	for child in parent.get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.disabled = not state
		# Also check nested collision shapes (like in Area2D)
		for grandchild in child.get_children():
			if grandchild is CollisionShape2D or grandchild is CollisionPolygon2D:
				grandchild.disabled = not state
