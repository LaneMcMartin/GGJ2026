## Oneway platform that will only let stuff pass through if it enters from BELOW.
## Also plays an animation to show this.
@tool
extends StaticBody2D

@export var area_2d: Area2D
@export var canvas_sprite_2d: CanvasSprite2D

var _is_enabled: bool = true

func _ready() -> void:
	area_2d.body_entered.connect(_on_body_entered)
	area_2d.body_exited.connect(_on_body_exited)
	
func _on_body_entered(body: Node2D) -> void:
	if _is_enabled and body.is_in_group("player"):
		# Check if body is coming from the passable direction.
		var local_pos = to_local(body.global_position)
		# If body is below the origin, pass. Note that the direction of this is LOCAL (meaning we can rotate this shape and it will work).
		if local_pos.y > 0:
			canvas_sprite_2d.play_once_forward()

func _on_body_exited(_body: Node2D) -> void:
	if _is_enabled:
		canvas_sprite_2d.play_once_backward()

## Called by parent Keygroup when this platform is toggled.
func _on_keygroup_toggled(state: bool) -> void:
	_is_enabled = state
	
	# Disable all collision shapes on this StaticBody2D and its children
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.disabled = not state
		# Also check nested collision shapes (like in Area2D)
		for grandchild in child.get_children():
			if grandchild is CollisionShape2D or grandchild is CollisionPolygon2D:
				grandchild.disabled = not state
