## A bit janky, but this is a custom extension of TileMapLayer that will change color according to what Keygroup it is under.
## IMPORTANT: Paint using the GREY tileset when making your level.
@tool
class_name PaletteTileMapLayer
extends TileMapLayer

const HUE_SHIFT_MATERIAL = preload("uid://dj5g3bffvpah4")
const _3D_TILES = preload("uid://cjk0ssha1qje4")

signal tileset_toggled

# Hue colors for each keygroup.
const GROUP_COLORS: Dictionary = {
	0: 0.5, # Yellow
	1: 0.0,  # Blue
	2: 0.65,  # Green
	3: 0.35,  # Red
}

# Reference to parent Keygroup.
var _keygroup: Keygroup = null

# Stuff to faciliate cool texture animation.
# Ripped from other object nodes...
const FRAME_POSITIONS := [0, 384, 768]
const CYCLE_TIME := 0.5
var current_frame := 0
var timer := 0.0
var canvas_texture: CanvasTexture
var diffuse_atlas: AtlasTexture
var normal_atlas: AtlasTexture

# Auto add the correct tileset and shader.
func _enter_tree() -> void:
	# Set up TileSet if missing.
	if tile_set == null:
		tile_set = _3D_TILES.duplicate()
	
	# Set up ShaderMaterial if missing.
	if material == null:
		material = HUE_SHIFT_MATERIAL.duplicate()

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
	var group_id: int = _keygroup.group_id
	var shader_material: ShaderMaterial = self.material
	shader_material.set_shader_parameter("hue_shift", GROUP_COLORS.get(group_id, 0))
	
	# Add to Tilesets group for player killing thing.
	add_to_group("Tilesets")
	
	# Get the atlases to animate them.
	var source = tile_set.get_source(1) as TileSetAtlasSource
	canvas_texture = source.texture as CanvasTexture
	diffuse_atlas = canvas_texture.diffuse_texture as AtlasTexture
	normal_atlas = canvas_texture.normal_texture as AtlasTexture


## Count time and cycle the frames by calling the region script.
func _process(delta: float) -> void:
	if !Engine.is_editor_hint():
		timer += delta
		if timer >= CYCLE_TIME:
			timer -= CYCLE_TIME
			current_frame = (current_frame + 1) % FRAME_POSITIONS.size()
			_update_region()
		

## Update the atlas region to animate it.
func _update_region() -> void:
	var new_x = FRAME_POSITIONS[current_frame]
	
	var diffuse_region = diffuse_atlas.region
	diffuse_region.position.x = new_x
	diffuse_atlas.region = diffuse_region
	
	var normal_region = normal_atlas.region
	normal_region.position.x = new_x
	normal_atlas.region = normal_region
	
	var source = tile_set.get_source(1) as TileSetAtlasSource
	var canvas_texture = source.texture as CanvasTexture
	canvas_texture.emit_changed()

## Custom implementation of the _on_keygroup_toggled that Keygroup calls. Toggles collision (via the flag that TileMapLayers look for).
func _on_keygroup_toggled(state: bool) -> void:
	collision_enabled = state
	tileset_toggled.emit(self)
