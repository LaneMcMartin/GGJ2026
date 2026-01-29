## Spring block that will be affected by gravity and will launch anything above it.
extends CharacterBody2D

@export_category("Children")
## The raycast node used for collision detection with an object above the spring.
@export var ray_cast_2d: RayCast2D

@export_category("Variables")
## The applied velocity to the player.
@export_range(50.0, 1000.0, 10.0) var applied_spring_velocity: float = 1000.0
## The debounce time on the spring (cooldown so we can't rapidly trigger it while overlapping).
@export var spring_cooldown_seconds: float = 1.0

var _debounce_timer: float = 0.0
var _is_active: bool = true

## Executed every physics frame.
func _physics_process(delta: float) -> void:
	# Subtract delta time from the timer.
	_debounce_timer = clampf(_debounce_timer - delta, 0.0, spring_cooldown_seconds)
	
	# Bounce the player if it touched the raycast and the debounce timer is done.
	if ray_cast_2d.is_colliding():
		var detected_collision: Object = ray_cast_2d.get_collider()
		if detected_collision is Player:
			if _debounce_timer == 0.0:
				if _is_active:
					detected_collision.velocity.y -= applied_spring_velocity
					_debounce_timer = spring_cooldown_seconds


## Executed according to state of Keygroup.
func _on_keygroup_toggled(state: bool) -> void:
	_is_active = state
