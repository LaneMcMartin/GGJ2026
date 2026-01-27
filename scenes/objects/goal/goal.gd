## The goal area that the player must reach to complete a level.
extends Area2D

## Emitted when a player enters the goal area.
signal goal_reached

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		goal_reached.emit()
