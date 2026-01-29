## A bit janky, but this is a custom extension of TileMapLayer that will change color according to what Keygroup it is under.
## IMPORTANT: Paint using the GREY tileset when making your level.
@tool
class_name PaletteTileMapLayer
extends TileMapLayer

signal tileset_toggled

# Editor preview colors for each Keygroup.
const GROUP_COLORS: Dictionary = {
	1: Color(0.6, 0.6, 1.0),  # Blue
	2: Color(0.6, 1.0, 0.6),  # Green
	3: Color(1.0, 0.6, 0.6),  # Red
}

# Reference to parent Keygroup.
var _keygroup: Keygroup = null

## Display a warning if the parent isn't a Keygroup.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _is_parent_keygroup():
		warnings.append("Parent must be a Keygroup node.")
	return warnings

## Check if the parent is a Keygroup.
func _is_parent_keygroup() -> bool:
	var parent = get_parent()
	return parent != null and parent.has_method("get") and "group_id" in parent

# Run on start.
func _ready() -> void:
	# Check if parent is Keygroup.
	if not _is_parent_keygroup():
		push_error("KeygroupTileMapLayer must be a child of a Keygroup node.")
		return
	
	# Yes! Store reference.
	_keygroup = get_parent()
	
	# IF we are in the editor, update hue to make it easier to see waht we are doing.
	if Engine.is_editor_hint():
		_update_preview()
	# Otherwise, set modualtion to white (default) BUT remap the tileset image that the TileMapLayer looks at.
	else:
		modulate = Color.WHITE
		_remap_source_ids()
		
	add_to_group("Tilesets")

## Update hue for editor preview.
func _update_preview() -> void:
	var group_id: int = _keygroup.group_id
	modulate = GROUP_COLORS.get(group_id, Color.MAGENTA)

## Remap the tileset image that the TileMapLayer uses.
func _remap_source_ids() -> void:
	var source_id: int = _keygroup.group_id
	
	for cell in get_used_cells():
		var atlas_coords = get_cell_atlas_coords(cell)
		var alt_tile = get_cell_alternative_tile(cell)
		set_cell(cell, source_id, atlas_coords, alt_tile)

## Custom implementation of the _on_keygroup_toggled that Keygroup calls. Toggles collision (via the flag that TileMapLayers look for).
func _on_keygroup_toggled(state: bool) -> void:
	collision_enabled = state
	tileset_toggled.emit(self)
