## This class is a parent container that will handle spawning a level. It will also detect when a level is won
## and when to load the next one. Fianlly, it will also allow reloading the level.
class_name LevelManager
extends Node

const LEVEL_DIRECTORY: String = "res://scenes/levels/"
const level_order: Array[String] = [
	"_tutorial-1",
	# "_tutorial-2",
	# "_tutorial-3",
	# "_tutorial-4",
	"_tutorial-5",
	"level-1"
]

var _current_level_index: int = 0
var _current_level: Node2D = null
var _player: Player = null

func _ready() -> void:
	_load_level(_current_level_index)
	
	_connect_reset_key()
	# In debug builds (or editor) conenct to debug signals.
	_try_connect_debug_signals()


## Debug exclusive function: connect to level skip hotkey.
func _try_connect_debug_signals() -> void:
	if OS.is_debug_build():
		GameManager.level_back.connect(func(): _load_level(_current_level_index - 1))
		GameManager.level_forward.connect(func(): _load_level(_current_level_index + 1))

func _connect_reset_key() -> void:
	GameManager.level_reset.connect(func(): _reset_level())

## Load a new level.
func _load_level(level_index: int) -> void:
	# Free the old level (if applicable).
	if _current_level != null:
		_current_level.queue_free()
	
	# Load the new one and conenct to the goal. Failsafe if the level index is out of range.
	if (level_index >= level_order.size()) or (level_index < 0):
		_current_level_index = 0
	else:
		_current_level_index = level_index
	_current_level = load(LEVEL_DIRECTORY + level_order[_current_level_index] + ".tscn").instantiate()
	self.add_child(_current_level)
	
	_player = _current_level.get_node("Player")
	
	_connect_goal()
	_connect_player_death()
	_subscribe_to_toggled_tileset()
	
func _reset_level() -> void:
	_load_level(_current_level_index)

## Finds the Goal node in the current level and connects to the goal_reached signal.
func _connect_goal() -> void:
	var goal: Area2D = _current_level.find_child("Goal", true, false)
	if goal and goal.has_signal("goal_reached"):
		goal.goal_reached.connect(_on_goal_reached)
		
func _connect_player_death() -> void:
	if _player and _player.has_signal("player_died"):
		_player.player_died.connect(_reset_level)

## Call when we got to the goal and go to the next level.
func _on_goal_reached() -> void:
	print_debug("Level " + str(_current_level_index) + " cleared!")
	_current_level_index += 1
	_load_level(_current_level_index)

func _subscribe_to_toggled_tileset() -> void:
	for tileset in _get_tilesets():
		tileset.tileset_toggled.connect(_on_tileset_toggled)		 
	
func _get_tilesets() -> Array[Node]:
	return get_tree().get_nodes_in_group("Tilesets")

func _on_tileset_toggled(tileset) -> void:
	if does_player_collide_with_layer(tileset):
		for ts in _get_tilesets():
			if ts.tileset_toggled.is_connected(_on_tileset_toggled):
				ts.tileset_toggled.disconnect(_on_tileset_toggled)
		_reset_level()

func does_player_collide_with_layer(tileset: PaletteTileMapLayer) -> bool:
	# Get player's position in tilemap coordinates
	var player_tile_pos = tileset.local_to_map(_player.global_position)
	
	# Check if there's a tile at the player's position
	var tile_data = tileset.get_cell_tile_data(player_tile_pos)
	
	# If there's a tile and it has collision, player would die
	if tile_data != null:
		# Check if this tile has collision shapes
		var collision_layer = tile_data.get_collision_polygons_count(0)
		if collision_layer > 0:
			return true
	
	return false
	
