## Handles the visual and audio effects when a player dies.
## This includes slow motion, camera zoom, vignette, and sound effects.
class_name DeathEffect
extends Node

const DEATH_SOUND = preload("uid://ce0u4hpyygfql")
const DEATH_ANIMATION_DURATION: float = 2.0

var _canvas_layer: CanvasLayer = null
var _death_vignette: ColorRect = null

func _init(canvas_layer: CanvasLayer, death_vignette: ColorRect) -> void:
	_canvas_layer = canvas_layer
	_death_vignette = death_vignette

## Play the complete death effect sequence for a specific player.
func play_death_animation(dead_player: Player) -> void:
	# Play death sound
	SoundManager.play_sound_with_pitch(DEATH_SOUND, randf_range(0.9, 1.1))
	
	var viewport_size := _canvas_layer.get_viewport().get_visible_rect().size
	
	# Slow down time
	Engine.time_scale = 0.25
	
	# Show vignette
	_death_vignette.visible = true
	
	# Create tweens - use IDLE mode and compensate for time scale
	var transform_tween := _canvas_layer.create_tween()
	transform_tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	transform_tween.set_speed_scale(1.0 / Engine.time_scale)  # Compensate for slow motion
	
	var vignette_tween := _canvas_layer.create_tween()
	vignette_tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	vignette_tween.set_speed_scale(1.0 / Engine.time_scale)  # Compensate for slow motion
	
	# Zoom in on the dead player by scaling and translating the CanvasLayer
	if dead_player:
		var zoom_factor := 1.5
		var player_screen_pos := dead_player.global_position
		
		# Calculate transform: scale around player position
		var new_transform := Transform2D()
		new_transform = new_transform.scaled(Vector2(zoom_factor, zoom_factor))
		# Translate to keep player centered
		var offset := viewport_size / 2.0 - player_screen_pos * zoom_factor
		new_transform.origin = offset
		
		transform_tween.tween_property(_canvas_layer, "transform", new_transform, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	# Fade in the red vignette
	vignette_tween.tween_property(_death_vignette.material, "shader_parameter/intensity", 0.8, 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	
	# Wait for the full animation duration (in real time, ignore time scale)
	var timer = _canvas_layer.get_tree().create_timer(DEATH_ANIMATION_DURATION, true, false, true)
	await timer.timeout
	
	# Reset everything
	Engine.time_scale = 1.0
	_death_vignette.visible = false
	# Extra safety: wait one frame to ensure everything is processed
	await _canvas_layer.get_tree().process_frame
	
	_death_vignette.material.set_shader_parameter("intensity", 0.0)
	_canvas_layer.transform = Transform2D.IDENTITY  # Reset to no zoom/pan
