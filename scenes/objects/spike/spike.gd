extends Node

func on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body._player_died()
