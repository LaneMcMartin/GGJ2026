class_name Ladder
extends Area2D

@export var ray_cast_2dr: RayCast2D
@export var ray_cast_2dl: RayCast2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
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
