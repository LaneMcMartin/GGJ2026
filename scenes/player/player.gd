## An auto-moving character that walks left/right and turns around when hitting walls.
## The player is affected by gravity like a standard platformer character.
@tool
class_name Player
extends CharacterBody2D

## The direction the player is moving.
enum Direction {
	LEFT = -1,
	RIGHT = 1,
}

@export_category("Movement")
## The horizontal movement speed in pixels per second.
@export_range(50.0, 250.0, 10.0) var speed: float = 200.0
## The starting direction of the player.
@export var starting_direction: Direction = Direction.LEFT:
	set(value):
		starting_direction = value
		_current_direction = value
		queue_redraw()  # Redraw direction indicator.

@export_category("Physics")
## Gravity strength in pixels per second squared.
@export var gravity: float = 980.0
## Maximum fall speed to prevent infinite acceleration.
@export var max_fall_speed: float = 1000.0

@export_category("Collision")
## The collision shape for the player.
@export var collision_shape: CollisionShape2D

@export_category("Visuals")
## The sprite representation of the player.
@export var sprite: AnimatedSprite2D

## The current movement direction.
var _current_direction: int = Direction.LEFT

## Whether the player is currently enabled (can move).
var _is_enabled: bool = true


func _ready() -> void:
	_current_direction = starting_direction
	floor_snap_length = 32.0
	update_sprite_direction()

func _physics_process(delta: float) -> void:
	# Don't run physics in editor.
	if Engine.is_editor_hint():
		return
	
	# Don't move if disabled.
	if not _is_enabled:
		return
	
	# Apply gravity.
	velocity.y += gravity * delta
	velocity.y = minf(velocity.y, max_fall_speed)
	
	# Apply horizontal movement.
	velocity.x = speed * _current_direction
	
	# Move and check for collisions.
	move_and_slide()
	
	# Check for wall collision and turn around.
	if is_on_wall():
		_turn_around()


## Reverses the player's direction.
func _turn_around() -> void:
	_current_direction *= -1
	update_sprite_direction()


## Flip the player sprite direction.
func update_sprite_direction():
	sprite.flip_h = (_current_direction == Direction.RIGHT)


## Called by the parent Keygroup when this player is toggled.
func _on_keygroup_toggled(enabled: bool) -> void:
	_is_enabled = enabled
	
	# Update collision.
	if collision_shape:
		collision_shape.disabled = not enabled
	
	# Update sprite opacity.
	if sprite and sprite is CanvasItem:
		sprite.modulate.a = 1.0 if enabled else 0.1
	
	# Stop movement when disabled.
	if not enabled:
		velocity = Vector2.ZERO
