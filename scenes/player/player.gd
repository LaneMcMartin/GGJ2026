## An auto-moving character that walks left/right and turns around when hitting walls.
## The player is affected by gravity like a standard platformer character.
@tool
class_name Player
extends CharacterBody2D

# Emitted when the player exits the screen
signal player_died

## The direction the player is moving.
enum Direction {
	LEFT = -1,
	RIGHT = 1,
}

## The direction the player is moving (up or down).
enum VerticalDirection {
	DOWN = -1,
	UP = 1,
}

## The movement states the player can be in.
enum State {
	WALKING, FALLING, SPRING, CLIMBING, WIN, PAUSED, DEATH
}
var current_state: State = State.WALKING: set = set_state
const STATE_ANIMATIONS: Array[String] = ["default", "air", "air", "climb", "win", "default", "death"]
const FOOTSTEP_SOUND = preload("uid://dx63s0t2a135h")
## Frames in the walking animation where footsteps should play.
const FOOTSTEP_FRAMES: Array[int] = [1, 4]  # Adjust these based on your animation

@export_category("Movement")
## The horizontal movement speed in pixels per second.
@export_range(50.0, 250.0, 10.0) var speed: float = 200.0
@export var climb_speed: float = 100.0
## The starting direction of the player.
@export var starting_direction: Direction = Direction.LEFT:
	set(value):
		starting_direction = value
		_current_direction = value
		queue_redraw()  # Redraw direction indicator.

@export_category("Physics")
## Gravity strengths in pixels per second squared.
@export var rising_gravity: float = 1500.0
@export var falling_gravity: float = 1500.0
## Maximum fall speed to prevent infinite acceleration.
@export var max_fall_speed: float = 1500.0

@export_category("Collision")
## The collision shape for the player.
@export var collision_shape: CollisionShape2D
@export var ray_cast_2d_ladder_up: RayCast2D
@export var ray_cast_2d_ladder_down: RayCast2D

@export_category("Visuals")
## The sprite representation of the player.
@export var sprite: AnimatedSprite2D

## The current movement direction.
var _current_direction: int = Direction.LEFT

## Whether the player is currently enabled (can move).
var _is_enabled: bool = true

## The climbing exit direction.
var _climbing_exit_direction: Direction = Direction.RIGHT
var _climbing_vertical_direction: VerticalDirection = VerticalDirection.UP

## We limit how often a player can turn around within a second.
# If the player turns around more than WALK_MAX_TURNS_PER_SEC, they will pause
# their walk for WALK_PAUSE_DURATION_SEC seconds.
# This can happen when many players are in a small space and keep bumping into each
# other and turning around repeatedly.
var _turn_around_times: Array[float] = []
var _walk_pause_time_left_sec: float = 0.0
const WALK_MAX_TURNS_PER_SEC: int = 5
const WALK_PAUSE_DURATION_SEC: float = 0.5


func get_current_direction() -> Direction:
	return _current_direction


func _ready() -> void:
	add_to_group("Players")
	_current_direction = starting_direction
	floor_snap_length = 32.0
	update_sprite_direction()
	
	# Reset velocity on spawn/respawn
	velocity = Vector2.ZERO
	
	# Connect to animation frame changes for footstep sounds.
	if sprite:
		sprite.frame_changed.connect(_on_sprite_frame_changed)
		
func _physics_process(delta: float) -> void:
	# Don't run physics in editor.
	if Engine.is_editor_hint():
		return
	
	# Don't move if disabled or dead.
	if not _is_enabled or current_state == State.DEATH:
		return
	
	# Handle pause timer.
	if current_state == State.PAUSED:
		_walk_pause_time_left_sec -= delta
		if _walk_pause_time_left_sec <= 0.0:
			current_state = State.WALKING
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	# If climbing, run that specific movement instead.
	if current_state == State.CLIMBING:
		resume_climbing()
		return
	
	# Apply gravity.
	if velocity.y < 0.0:
		velocity.y += rising_gravity * delta
	else:
		velocity.y += falling_gravity * delta
	velocity.y = minf(velocity.y, max_fall_speed)
	
	# Apply horizontal movement.
	velocity.x = speed * _current_direction
	
	# Move and check for collisions.
	move_and_slide()
	
	# Check for wall collision and turn around.
	if is_on_wall() and (current_state != State.DEATH):
		_turn_around()
		
	# Check for ground collision.
	if is_on_floor() and (current_state != State.WALKING):
		current_state = State.WALKING
		
	# Check for slope rotation.
	if is_on_floor() and (current_state == State.WALKING):
		align_to_slope(delta)

## Align the player normal to the slope.
func align_to_slope(delta: float, rotation_speed: float = 10.0) -> void:
	var target_angle: float = 0.0
	if is_on_floor():
		target_angle = get_floor_normal().angle() + PI/2
	rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)

## Function that is called automatically when the player state is changed.
## Can handle specific behaviour that happens WHEN a state is changed.
## Return false if the state didn't change.
func set_state(new_state: State) -> bool:
	# Don't transition if the states match.
	if current_state == new_state:
		return false
	
	# Once dead, stay dead (can't change to any other state)
	if current_state == State.DEATH:
		return false
	
	# Actually set the state.
	current_state = new_state
	
	# Play new aniamtion.
	sprite.play(STATE_ANIMATIONS[current_state])
	return true
	

## Reverses the player's direction.
func _turn_around() -> void:
	var current_time := Time.get_ticks_msec() / 1000.0
	
	# Add current turn time.
	_turn_around_times.append(current_time)
	
	# Remove turn times older than 1 second.
	_turn_around_times = _turn_around_times.filter(func(time): return current_time - time <= 1.0)
	
	# Check if we've turned around too many times.
	if _turn_around_times.size() > WALK_MAX_TURNS_PER_SEC and current_state == State.WALKING:
		# Pause for the configured duration.
		current_state = State.PAUSED
		_walk_pause_time_left_sec = WALK_PAUSE_DURATION_SEC
		_turn_around_times.clear()
		return
	
	_current_direction *= -1
	update_sprite_direction()


## Flip the player sprite direction.
func update_sprite_direction():
	sprite.flip_h = (_current_direction == Direction.LEFT)

## Called when the sprite animation frame changes.
func _on_sprite_frame_changed() -> void:
	# Only play footsteps when walking and on the ground.
	if current_state == State.WALKING and is_on_floor():
		var current_frame = sprite.frame
		if current_frame in FOOTSTEP_FRAMES:
			var player = SoundManager.play_sound(FOOTSTEP_SOUND)
			player.volume_db = 6.0  # Increase volume (default is 0)

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
		
		
func _player_died():
	# Players who are disabled (eg: have reached a goal) cannot die.
	if not _is_enabled:
		print_debug("Tried to kill a player who is disabled and cannot die. Ignoring.")
		return
	
	# Set death state to trigger death animation (and lock state)
	set_state(State.DEATH)
	
	# Don't play sound here - it will be played in the death animation
	player_died.emit()


func start_climbing(exit_direction: Direction, ladder_x: float) -> void:
	# Set climbing state.
	if !set_state(State.CLIMBING):
		return

	# Snap to ladder center so raycasts align properly.
	global_position.x = ladder_x

	# Force raycasts to update immediately after position change.
	ray_cast_2d_ladder_up.force_raycast_update()
	ray_cast_2d_ladder_down.force_raycast_update()

	# Set exit direction.
	_climbing_exit_direction = exit_direction
	
	# Face the exit direction so player knows which way they'll exit.
	_current_direction = exit_direction
	update_sprite_direction()

	# Figure out if we are going up or down based on which direction has more ladder.
	var up_collision: Object = ray_cast_2d_ladder_up.get_collider()
	var down_collision: Object = ray_cast_2d_ladder_down.get_collider()
	if (up_collision is Ladder) and (down_collision is Ladder):
		# In the middle of a ladder stack - default to climbing up.
		_climbing_vertical_direction = VerticalDirection.UP
	elif up_collision is Ladder:
		# Ladder above, so climb up.
		_climbing_vertical_direction = VerticalDirection.UP
	elif down_collision is Ladder:
		# Ladder below, so climb down.
		_climbing_vertical_direction = VerticalDirection.DOWN
	else:
		# No ladder detected in either direction - this shouldn't happen normally.
		# Default to up.
		_climbing_vertical_direction = VerticalDirection.UP
	
	
func resume_climbing() -> void:
	# Apply no horizontal movement and velocity in our climb direction.
	var current_climb_speed = climb_speed * -1.0 * _climbing_vertical_direction
	velocity = Vector2(0.0, current_climb_speed)

	# Move and check for collisions.
	move_and_slide()

	# Check if we should stop climbing.
	# We exit when NEITHER raycast detects a ladder anymore.
	# This means we've fully exited the ladder column.
	ray_cast_2d_ladder_up.force_raycast_update()
	ray_cast_2d_ladder_down.force_raycast_update()

	var ladder_above := ray_cast_2d_ladder_up.is_colliding()
	var ladder_below := ray_cast_2d_ladder_down.is_colliding()
	
	# Check if climbing up and there's a disabled ladder above.
	if _climbing_vertical_direction == VerticalDirection.UP and ladder_above:
		var collider_above = ray_cast_2d_ladder_up.get_collider()
		if collider_above is Ladder and not collider_above.is_enabled():
			stop_climbing()
			return

	if not ladder_above and not ladder_below:
		stop_climbing()

func stop_climbing() -> void:
	# Set player direction to the cached one and set movement to walking.
	_current_direction = _climbing_exit_direction
	update_sprite_direction()
	current_state = State.WALKING

## Enter special state where we win the level.
func win_level() -> void:
	# Disable player (makes them unkillable and non-collidable).
	_is_enabled = false
	
	# Disable collision shape.
	if collision_shape:
		collision_shape.disabled = true
	
	# Move to a collision layer that nothing else collides with (layer 32).
	# This prevents won players from blocking active players.
	collision_layer = 0  # Not on any layer
	collision_mask = 0   # Doesn't collide with anything
	
	# Stop movement and play animation.
	sprite.animation_finished.connect(_fade_out)
	current_state = State.WIN

## Helper for fading out after win.
func _fade_out() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0.1), 1.0)
