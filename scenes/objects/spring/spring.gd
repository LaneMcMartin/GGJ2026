## Spring block that will be affected by gravity and will launch anything above it.
extends CharacterBody2D

@export_category("Children")
## The raycast node used for collision detection with an object above the spring.
@export var ray_cast_2d: RayCast2D
@export var sprite_2d: Sprite2D

@export_category("Variables")
## The applied velocity to the player.
@export_range(50.0, 1000.0, 10.0) var applied_spring_velocity: float = 1000.0
## The debounce time on the spring (cooldown so we can't rapidly trigger it while overlapping).
@export var spring_cooldown_seconds: float = 1.0

@export_category("Physics")
## Gravity strength in pixels per second squared.
@export var gravity: float = 1500.0
## Maximum fall speed to prevent infinite acceleration.
@export var max_fall_speed: float = 1500.0

const FRAME_POSITIONS := [0, 64, 128]
const CYCLE_TIME := 0.5
const SPRING_FX = preload("uid://d01cqd7erptys")

var _debounce_timer: float = 0.0
var _is_enabled: bool = true
var current_frame := 0
var timer := 0.0

func _ready() -> void:
	sprite_2d.region_enabled = true
	# Each instance starts at a different frame
	current_frame = randi() % FRAME_POSITIONS.size()
	_update_region()
	
func _process(delta: float) -> void:
	timer += delta
	if timer >= CYCLE_TIME:
		timer -= CYCLE_TIME
		current_frame = (current_frame + 1) % FRAME_POSITIONS.size()
		_update_region()

func _update_region() -> void:
	sprite_2d.region_rect.position.x = FRAME_POSITIONS[current_frame]

## Executed every physics frame.
func _physics_process(delta: float) -> void:
	if (_is_enabled):
		# Apply gravity
		velocity.y += gravity * delta
		velocity.y = minf(velocity.y, max_fall_speed)
		# Move and slide to handle physics and collisions
		move_and_slide()
		
		# Check if spring is falling and crushing the player
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider is Player:
				collider._player_died()
	
	# Subtract delta time from the timer.
	_debounce_timer = clampf(_debounce_timer - delta, 0.0, spring_cooldown_seconds)
	
	# Bounce the player if it touched the raycast and the debounce timer is done.
	if ray_cast_2d.is_colliding():
		var detected_collision: Object = ray_cast_2d.get_collider()
		if detected_collision is Player:
			if _debounce_timer == 0.0:
				if _is_enabled:
					var launch_direction := _get_launch_direction()
					detected_collision.velocity += launch_direction * applied_spring_velocity
					detected_collision.current_state = Player.State.SPRING
					SoundManager.play_sound_with_pitch(SPRING_FX, randf_range(0.9, 1.1))
					_debounce_timer = spring_cooldown_seconds

## Called by Keygroup when toggled.
func _on_keygroup_toggled(state: bool) -> void:
	_is_enabled = state
	
	# Disable all collision shapes so player can walk through disabled springs
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.disabled = not state

## Figure ut which way to impulse the colliding body.
func _get_launch_direction() -> Vector2:
	return Vector2.UP.rotated(rotation)
