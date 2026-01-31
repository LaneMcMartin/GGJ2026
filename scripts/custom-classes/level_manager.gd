## This class is a parent container that will handle spawning a level. It will also detect when a level is won
## and when to load the next one. Fianlly, it will also allow reloading the level.
class_name LevelManager
extends Node

const LEVEL_DIRECTORY: String = "res://scenes/levels/"
const level_order: Array[String] = [
	"_tutorial-1",
	"_tutorial-2",
	"_tutorial-3",
	"_tutorial-4",
	"_tutorial-5",
	"_tutorial-6",
	"_tutorial-falling-spring",
	"_tutorial-7",
]

## Duration of the countdown before level starts (in seconds).
const COUNTDOWN_DURATION: float = 2.0

var _current_level_index: int = 0
var _current_level: Node2D = null
var _player: Player = null
var _transition: ColorRect = null
var _pending_level_index: int = -1

func _ready() -> void:
	# Add to LevelManager group so goals can find us
	add_to_group("LevelManager")
	
	GameManager.escape_pressed.connect(_on_escape_pressed)
	

	# Get reference to the Transition node (sibling).
	_transition = get_node("../Transition")
	_transition.transition_closed.connect(_on_transition_closed)
	_transition.transition_opened.connect(_on_transition_opened)

	_load_level(_current_level_index, true)  # Skip transition for initial load

	_connect_reset_key()

	GameManager.level_complete.connect(_level_complete)

	# In debug builds (or editor) conenct to debug signals.
	_try_connect_debug_signals()


## Debug exclusive function: connect to level skip hotkey.
func _try_connect_debug_signals() -> void:
	if OS.is_debug_build():
		GameManager.level_back.connect(func(): _load_level(_current_level_index - 1, true))
		GameManager.level_forward.connect(func(): _load_level(_current_level_index + 1, true))

func _connect_reset_key() -> void:
	GameManager.level_reset.connect(func(): _reset_level())

## Load a new level. If skip_transition is true, the level starts immediately (used for initial load).
func _load_level(level_index: int, skip_transition: bool = false) -> void:
	# Free the old level (if applicable).
	if _current_level != null:
		_current_level.queue_free()

	# Load the new one and connect to the goal. Failsafe if the level index is out of range.
	if (level_index >= level_order.size()) or (level_index < 0):
		_current_level_index = 0
	else:
		_current_level_index = level_index
	_current_level = load(LEVEL_DIRECTORY + level_order[_current_level_index] + ".tscn").instantiate()
	self.add_child(_current_level)

	_player = _current_level.get_node("Player")

	_connect_player_death()
	_subscribe_to_toggled_tileset()

	if skip_transition:
		# Start immediately without transition/countdown.
		GameManager.level_start.emit()
	else:
		# Disable player until countdown finishes, then open the transition.
		_player._is_enabled = false
		_transition.open_transition()

## Called when the close transition finishes (screen is fully covered).
func _on_transition_closed() -> void:
	# Just wait a tiny bit to make the transition look nice.
	await get_tree().create_timer(0.5).timeout
	
	# Now safe to load the pending level.
	if _pending_level_index >= 0:
		_load_level(_pending_level_index)
		_pending_level_index = -1

## Called when the open transition finishes (screen is fully visible).
func _on_transition_opened() -> void:
	# Start the countdown before enabling player.
	_start_countdown()

## Start countdown timer before level begins.
func _start_countdown() -> void:
	var timer: SceneTreeTimer = get_tree().create_timer(COUNTDOWN_DURATION)
	timer.timeout.connect(_on_countdown_finished)

## Called when countdown finishes - enable the player and start the level.
func _on_countdown_finished() -> void:
	if _player:
		_player._is_enabled = true
	GameManager.level_start.emit()
	
func _reset_level() -> void:
	_load_level(_current_level_index, true)  # Skip transition for quick restart
		
func _connect_player_death() -> void:
	if _player and _player.has_signal("player_died"):
		_player.player_died.connect(_reset_level)

## Call when we got to the goal and go to the next level (legacy - now uses signal flow).
func _on_goal_reached() -> void:
	print_debug("Level " + str(_current_level_index) + " cleared!")
	_pending_level_index = _current_level_index + 1

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

# Open pause menu and pause game
func _on_escape_pressed() -> void:
	get_tree().paused = true
	var pause_menu = preload("res://scenes/options/options.tscn").instantiate()
	pause_menu.show_unpause_button = true
	add_child(pause_menu)

func _level_complete() -> void:
	# Store the next level index; actual loading happens after transition closes.
	_pending_level_index = _current_level_index + 1
