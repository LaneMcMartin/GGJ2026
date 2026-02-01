## The goal area that the player must reach to complete a level.
extends Area2D

## Emitted when a player reaches this goal.
signal player_reached_goal(player: Player, goal: Node2D)

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
	add_to_group("Goals")
	body_entered.connect(_on_body_entered)
	sprite_2d.region_enabled = true
	# Each instance starts at a different frame
	current_frame = randi() % FRAME_POSITIONS.size()
	_update_region()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		# Check if player already won (to prevent double-counting).
		if body.current_state == body.State.WIN:
			return
		
		# Disable player (makes them unkillable and non-collidable).
		body._is_enabled = false
		
		# Disable collision so disabled players don't collide with other players.
		if body.collision_shape:
			body.collision_shape.disabled = true
		
		# Start win animation and fade player out.
		body.win_level()
		
		# Tween player to goal center.
		var tween: Tween = create_tween()
		tween.tween_property(body, "global_position", self.global_position, 0.25)
		
		# Notify LevelManager directly that this player reached a goal.
		var level_managers = get_tree().get_nodes_in_group("LevelManager")
		if level_managers.size() > 0:
			var level_manager = level_managers[0]
			if level_manager.has_method("on_player_reached_goal"):
				level_manager.on_player_reached_goal(body, self)
