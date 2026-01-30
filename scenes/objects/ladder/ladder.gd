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
		if (right_collison != null) and (left_collison != null):
			return
		if right_collison is Player:
			right_collison.start_climbing(Player.Direction.LEFT)
		if left_collison is Player:
			right_collison.start_climbing(Player.Direction.RIGHT)
