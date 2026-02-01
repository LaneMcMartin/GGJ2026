## Keygroup Manager. This script is an Autoload - it is automatically loaded in all of the time.
extends Node

# Sound for keygroup toggle.
const MASKUNMASK = preload("uid://mycf6otnqiun")

## Emitted when a keygroup's enabled state changes.
## Keygroup nodes listen to this to update their children.
signal keygroup_toggled(group_id: int, is_enabled: bool)

## Tracks the enabled state of each group (1-4).
## True = Enabled, False = Disabled.
var _group_states: Dictionary = {
	1: true,
	2: true,
	3: true,
	4: true,
}

## All registered Keygroup nodes, by group_id.
## Each entry is an array of Keygroup nodes.
var _registered_keygroups: Dictionary = {
	1: [],
	2: [],
	3: [],
	4: [],
}

## Returns the current enabled state of a group.
func is_group_enabled(group_id: int) -> bool:
	if group_id < 1 or group_id > 4:
		push_warning("KeygroupManager: Invalid group_id %d" % group_id)
		return false
		
	return _group_states.get(group_id, true)


## Sets the enabled state of a group directly.
func set_group_enabled(group_id: int, enabled: bool) -> void:
	if group_id < 1 or group_id > 4:
		push_warning("KeygroupManager: Invalid group_id %d" % group_id)
		return
		
	_group_states[group_id] = enabled
	keygroup_toggled.emit(group_id, enabled)


## Toggles a groups enabled state.
func toggle_group(group_id: int) -> void:
	if group_id < 1 or group_id > 4:
		push_warning("KeygroupManager: Invalid group_id %d" % group_id)
		return
		
	_group_states[group_id] = not _group_states[group_id]
	keygroup_toggled.emit(group_id, _group_states[group_id])
	
	
## Registers a Keygroup node with the manager.
## Called automatically by Keygroup nodes when they enter the tree.
func register_keygroup(keygroup: Node, group_id: int) -> void:
	if group_id < 1 or group_id > 4:
		push_warning("KeygroupManager: Cannot register keygroup with invalid id %d" % group_id)
		return
		
	if keygroup not in _registered_keygroups[group_id]:
		_registered_keygroups[group_id].append(keygroup)


## Unregisters a Keygroup node from the manager.
## Called automatically by Keygroup nodes when they exit the tree.
func unregister_keygroup(keygroup: Node, group_id: int) -> void:
	if group_id < 1 or group_id > 4:
		push_warning("KeygroupManager: Cannot register keygroup with invalid id %d" % group_id)
		return
		
	_registered_keygroups[group_id].erase(keygroup)


## Resets all groups to their default states.
## Useful when restarting a level.
func reset_all_groups() -> void:
	for group_id in _group_states.keys():
		_group_states[group_id] = true
	
	# Notify all registered keygroups to check their initial states.
	for group_id in _registered_keygroups.keys():
		for keygroup in _registered_keygroups[group_id]:
			if keygroup.has_method("apply_initial_state"):
				keygroup.apply_initial_state()


func _unhandled_input(event: InputEvent) -> void:
	# Handle keygroup toggle inputs.
	if event.is_action_pressed("toggle_group_1"):
		toggle_group(1)
		SoundManager.play_sound_with_pitch(MASKUNMASK, 0.9)
	elif event.is_action_pressed("toggle_group_2"):
		toggle_group(2)
		SoundManager.play_sound_with_pitch(MASKUNMASK, 1.0)
	elif event.is_action_pressed("toggle_group_3"):
		toggle_group(3)
		SoundManager.play_sound_with_pitch(MASKUNMASK, 1.1)
	elif event.is_action_pressed("toggle_group_4"):
		toggle_group(4)
