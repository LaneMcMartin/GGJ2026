## Incredibly niche custom class that is basically for animating 64x64 tiles w/ canvas textures (diffusion + normal).
class_name CanvasSprite2D
extends Sprite2D

enum PlayMode { STOPPED, FORWARD, BACKWARD }

@export var frame_width: float = 64
@export var frame_height: float = 64
@export var number_of_frames: int = 3
@export var time_per_frame: float = 0.5
@export var loop: bool = true
@export var play_mode: PlayMode = PlayMode.STOPPED

var current_frame := 0
var timer := 0.0

signal animation_finished

func _process(delta: float) -> void:
	if play_mode == PlayMode.STOPPED:
		return
	
	timer += delta
	if timer >= time_per_frame:
		timer -= time_per_frame
		_advance_frame()
		
		
func _advance_frame() -> void:
	match play_mode:
		PlayMode.FORWARD:
			if current_frame < number_of_frames - 1:
				current_frame += 1
				_update_region()
			elif loop:
				current_frame = 0
				_update_region()
			else:
				play_mode = PlayMode.STOPPED
				animation_finished.emit()
		
		PlayMode.BACKWARD:
			if current_frame > 0:
				current_frame -= 1
				_update_region()
			elif loop:
				current_frame = number_of_frames - 1
				_update_region()
			else:
				play_mode = PlayMode.STOPPED
				animation_finished.emit()
				
				
func _update_region() -> void:
	region_rect.position.x = current_frame * frame_width
	
	
## Play forward: looping based on the loop flag.
func play() -> void:
	play_mode = PlayMode.FORWARD
	
	
## Play from frame 0 to the last frame then stop.
func play_once_forward() -> void:
	current_frame = 0
	timer = 0.0
	loop = false
	play_mode = PlayMode.FORWARD
	_update_region()
	
	
## Play from the last frame to frame 0 then stop.
func play_once_backward() -> void:
	current_frame = number_of_frames - 1
	timer = 0.0
	loop = false
	play_mode = PlayMode.BACKWARD
	_update_region()
	
	
## Stop on the current frame.
func stop() -> void:
	play_mode = PlayMode.STOPPED
