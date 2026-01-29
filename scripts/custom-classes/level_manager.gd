## This class is a parent container that will handle spawning a level. It will also detect when a level is won
## and when to load the next one. Fianlly, it will also allow reloading the level.
class_name LevelManager
extends Node

const LEVEL_DIRECTORY: String = "res://scenes/levels/"
const level_order: Array[String] = ["new_tileset", "nico-test", "1", "2", "nico-test-clone"]

var _current_level_index: int = 0
var _current_level: Node2D = null

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
	_connect_goal()
	_connect_player_death()
	
func _reset_level() -> void:
	_load_level(_current_level_index)

## Finds the Goal node in the current level and connects to the goal_reached signal.
func _connect_goal() -> void:
	var goal: Area2D = _current_level.find_child("Goal", true, false)
	if goal and goal.has_signal("goal_reached"):
		goal.goal_reached.connect(_on_goal_reached)
		
func _connect_player_death() -> void:
	var player: Player = _current_level.get_node("Player")
	if player and player.has_signal("player_died"):
		player.player_died.connect(_reset_level)


## Call when we got to the goal and go to the next level.
func _on_goal_reached() -> void:
	print_debug("Level " + str(_current_level_index) + " cleared!")
	_current_level_index += 1
	_load_level(_current_level_index)
