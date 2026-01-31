class_name Area2DTweener
extends Area2D

@onready var parent = get_parent() as TileMapLayer
@onready var parent_scale = parent.transform.get_scale()
@onready var parent_position = parent.position
@onready var tile_size = parent.tile_set.tile_size as Vector2

func _ready() -> void:	
	var actual_tile_size = tile_size * parent_scale / 2
	var collision_node = self.get_child(0) as CollisionShape2D
	
	collision_node.shape.size = tile_size
	collision_node.position = Vector2.ZERO

func _on_mouse_entered() -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	var scale_factor = 1.15
	
	var tile_map_size = Vector2(parent.get_used_rect().size) * tile_size
	var offset = tile_map_size * parent_scale * (1 - scale_factor) / 2
	
	tween.tween_property(parent, "scale", parent_scale * scale_factor, 0.25)
	tween.parallel().tween_property(parent, "position", parent_position + offset, 0.25)

func _on_mouse_exited() -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(parent, "scale", parent_scale, 0.25)
	tween.parallel().tween_property(parent, "position", parent_position, 0.25)
