## Oneway platform that will only let stuff pass through if it enters from BELOW.
## Also plays an animation to show this.
@tool
extends StaticBody2D

@export var area_2d: Area2D
@export var canvas_sprite_2d: CanvasSprite2D
@export var preview_sprite: Sprite2D

func _ready() -> void:
	area_2d.body_entered.connect(_on_body_entered)
	area_2d.body_exited.connect(_on_body_exited)
	
	# Use the preview sprite if in editor.
	if Engine.is_editor_hint():
		canvas_sprite_2d.hide()
		preview_sprite.show()
	else:
		canvas_sprite_2d.show()
		preview_sprite.hide()
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Check if body is coming from the passable direction.
		var local_pos = to_local(body.global_position)
		# If body is below the origin, pass. Note that the direction of this is LOCAL (meaning we can rotate this shape and it will work).
		if local_pos.y > 0:
			canvas_sprite_2d.play_once_forward()

func _on_body_exited(_body: Node2D) -> void:
	canvas_sprite_2d.play_once_backward()
