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
	
	# Figure out which raycast the player touched.
	# AKA what side they approached from.
	if body is Player:
		var right_collison: Object = ray_cast_2dr.get_collider()
		var left_collison: Object = ray_cast_2dl.get_collider()
		# If both raycasts detect player, they're directly above/below - ignore.
		if (right_collison is Player) and (left_collison is Player):
			return
		# Player approached from the right (detected by right raycast) -> exit left.
		if right_collison is Player:
			right_collison.start_climbing(Player.Direction.LEFT, global_position.x)
		# Player approached from the left (detected by left raycast) -> exit right.
		elif left_collison is Player:
			left_collison.start_climbing(Player.Direction.RIGHT, global_position.x)

## Called by parent Keygroup when this ladder is toggled.
func _on_keygroup_toggled(new_state: bool) -> void:
	_is_enabled = new_state
	
	# If ladder is disabled while player is climbing, make them fall
	if not _is_enabled:
		for body in get_overlapping_bodies():
			if body is Player and body.current_state == Player.State.CLIMBING:
				body.stop_climbing()
