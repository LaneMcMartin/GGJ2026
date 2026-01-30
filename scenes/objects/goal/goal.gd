## The goal area that the player must reach to complete a level.
extends Area2D

@export var sprite_2d: Sprite2D

const FRAME_POSITIONS := [0, 128, 256]
const CYCLE_TIME := 0.5

var current_frame := 0
var timer := 0.0

func _process(delta: float) -> void:
	timer += delta
	if timer >= CYCLE_TIME:
		timer -= CYCLE_TIME
		current_frame = (current_frame + 1) % FRAME_POSITIONS.size()
		_update_region()

func _update_region() -> void:
	sprite_2d.region_rect.position.x = FRAME_POSITIONS[current_frame]

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	sprite_2d.region_enabled = true
	# Each instance starts at a different frame
	current_frame = randi() % FRAME_POSITIONS.size()
	_update_region()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var level_manager = get_tree().get_first_node_in_group("LevelManager")
		if level_manager:
			level_manager._on_goal_reached()
