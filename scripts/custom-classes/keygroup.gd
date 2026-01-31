## Any child of this class will be toggled by the key associated with it.
## Alternatively, if the class has a specific property, that function will be called too.
class_name Keygroup
extends Node2D

# Export Settings ##
## Settings related to this keygroup.
@export_category("Keygroup Settings")
## The group ID (0-4). Determines which key toggles this group.
@export_range(0, 4) var group_id: int = 1:
	set(value):
		group_id = clampi(value, 0, 4)
		_update_children_appearance()
		# Re-register with manager if group changes.
		if _is_registered and not Engine.is_editor_hint():
			KeygroupManager.unregister_keygroup(self, group_id)
			KeygroupManager.register_keygroup(self, group_id)
## Whether this group is enabled when the level begins.
@export var starts_enabled: bool = true


# State ##
## Current enabled state of this keygroup.
var is_enabled: bool = true
## Track whether we've registered with the manager.
var _is_registered: bool = false


# Run on entry in scene.
func _ready() -> void:
	# Apply the starting state.
	is_enabled = starts_enabled
	
	# If we are NOT inside the editor (and the game is actually running).
	if not Engine.is_editor_hint():
		# Register with the manager.
		KeygroupManager.register_keygroup(self, group_id)
		KeygroupManager.keygroup_toggled.connect(_on_manager_toggled)
		_is_registered = true
		
		# Set initial state in the manager.
		KeygroupManager.set_group_enabled(group_id, starts_enabled)
	
	# Update appearance for editor preview.
	#_update_children_appearance()  # TODO


# Run just prior to exiting scene.
func _exit_tree() -> void:
	if not Engine.is_editor_hint() and _is_registered:
		KeygroupManager.unregister_keygroup(self, group_id)
		if KeygroupManager.keygroup_toggled.is_connected(_on_manager_toggled):
			KeygroupManager.keygroup_toggled.disconnect(_on_manager_toggled)
		_is_registered = false

# Run when we detect that the children were moved in the editor.
func _notification(what: int) -> void:
	if what == NOTIFICATION_CHILD_ORDER_CHANGED:
		#_update_children_appearance()  # TODO
		pass

## Update child node appearance (mostly for tilemap).
func _update_children_appearance() -> void:
	for child in get_children():
		if child.has_method("_update_preview"):
			child._update_preview()

## Called by the KeygroupManager when this group is toggled.
func _on_manager_toggled(toggled_group_id: int, enabled: bool) -> void:
	if toggled_group_id != group_id:
		return
	
	is_enabled = enabled
	_apply_toggle_to_children(enabled)


## Applies the initial state. Called by KeygroupManager during level reset.
func apply_initial_state() -> void:
	is_enabled = starts_enabled
	_apply_toggle_to_children(is_enabled)
	KeygroupManager.set_group_enabled(group_id, is_enabled)


## Applies the toggle state to all children.
func _apply_toggle_to_children(enabled: bool) -> void:
	var target_alpha: float = 1.0 if enabled else 0.1
	self.modulate.a = target_alpha
	
	for child in get_children():
		_apply_toggle_to_node(child, enabled)
		

## Apply the transparency and collision change to the given node.
func _apply_toggle_to_node(node: Node, enabled: bool) -> void:
	# Always apply default toggle behavior (opacity + collision).
	_apply_default_toggle(node, enabled)
	
	# Also call custom handler (if the child has one).
	if node.has_method("_on_keygroup_toggled"):
		node._on_keygroup_toggled(enabled)
	
	# Recursively apply to children.
	var children = node.get_children()
	for child in children:
		_apply_toggle_to_node(child, enabled)
		
		
## Default toggle behavior for nodes that don't implement _on_keygroup_toggled.
func _apply_default_toggle(node: Node, enabled: bool) -> void:
	# Handle visibility (CanvasItem).
	#if node is CanvasItem:
		#var target_alpha: float = 1.0 if enabled else 0.1
		#node.modulate.a = target_alpha
	
	# Handle collision (CollisionShape2D / CollisionPolygon2D).
	if node is CollisionShape2D or node is CollisionPolygon2D:
		node.disabled = not enabled
