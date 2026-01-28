## Singleton used sparingly for very high-level stuff.
extends Node

## Debug switch level back and forward with "[" and "]" keys.
signal level_back
signal level_forward
func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	
	var key := event as InputEventKey
	if key and key.pressed and not key.echo:
		if key.keycode == KEY_BRACKETLEFT:
			level_back.emit()
		elif key.keycode == KEY_BRACKETRIGHT:
			level_forward.emit()
