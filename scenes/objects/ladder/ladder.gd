class_name Ladder
extends Area2D

@export var ray_cast_2dr: RayCast2D
@export var ray_cast_2dl: RayCast2D

var _is_enabled: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Don't allow climbing if ladder is masked out
	if not _is_enabled:
		return
	
	if body is Player:
		_start_player_climbing(body, false)

## Start the player climbing, determining exit direction from raycasts.
func _start_player_climbing(player: Player, allow_both_raycasts: bool = false) -> void:
	ray_cast_2dr.force_raycast_update()
	ray_cast_2dl.force_raycast_update()
	
	var right_collision: Object = ray_cast_2dr.get_collider()
	var left_collision: Object = ray_cast_2dl.get_collider()
	
	# If both raycasts detect player, they're directly above/below
	if (right_collision is Player) and (left_collision is Player):
		# Ignore when entering from top/bottom
		if not allow_both_raycasts:
			return 
		# When player overlaps with a disabled ladder which we enable, start climbing in current direction
		player.start_climbing(player._current_direction, global_position.x)
	elif right_collision is Player:
		player.start_climbing(Player.Direction.LEFT, global_position.x)
	elif left_collision is Player:
		player.start_climbing(Player.Direction.RIGHT, global_position.x)
	elif allow_both_raycasts:
		# When player overlaps with a disabled ladder which we enable, start climbing in current direction
		# In this case, somehow the raycast collision is not detected.
		# Note (Nico): I believe this can happen when we enable ladder and player is overlapping with it
		player.start_climbing(player._current_direction, global_position.x)

## Called by parent Keygroup when this ladder is toggled.
func _on_keygroup_toggled(new_state: bool) -> void:
	_is_enabled = new_state
	
	if not _is_enabled:
		# If ladder is disabled while player is climbing, make them fall
		for body in get_overlapping_bodies():
			if body is Player and body.current_state == Player.State.CLIMBING:
				body.stop_climbing()
	else:
		# If ladder is enabled while player is overlapping with it, start climbing
		for body in get_overlapping_bodies():
			if body is Player:
				_start_player_climbing(body, true)
