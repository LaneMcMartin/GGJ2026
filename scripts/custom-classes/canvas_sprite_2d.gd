## Incredibly niche custom class that is basically for animating 64x64 tiles w/ canvas textures (diffusion + normal).
class_name CanvasSprite2D
extends Sprite2D

enum PlayMode { STOPPED, FORWARD, BACKWARD }

@export var time_per_frame: float = 0.5
@export var loop: bool = true
@export var play_mode: PlayMode = PlayMode.STOPPED
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
			if frame < hframes - 1:
				frame += 1
			elif loop:
				frame = 0
			else:
				play_mode = PlayMode.STOPPED
				animation_finished.emit()
		
		PlayMode.BACKWARD:
			if frame > 0:
				frame -= 1
			elif loop:
				frame = hframes - 1
			else:
				play_mode = PlayMode.STOPPED
				animation_finished.emit()
	
## Play forward: looping based on the loop flag.
func play() -> void:
	play_mode = PlayMode.FORWARD
	
	
## Play from frame 0 to the last frame then stop.
func play_once_forward() -> void:
	frame = 0
	timer = 0.0
	loop = false
	play_mode = PlayMode.FORWARD
	
	
## Play from the last frame to frame 0 then stop.
func play_once_backward() -> void:
	frame = hframes - 1
	timer = 0.0
	loop = false
	play_mode = PlayMode.BACKWARD
	
	
## Stop on the current frame.
func stop() -> void:
	play_mode = PlayMode.STOPPED
