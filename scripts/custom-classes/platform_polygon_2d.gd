## Custom class to create a polygon platform with collision.
class_name  PlatformPolygon2D
extends Polygon2D

func _ready() -> void:
	# Create a new StaticBody2D (aka a "hitbox"), give it the same collision shape as the Polygon2D (which is purely visual),
	# and add the StaticBody2D (with the CollisionPolygon2D child) as a child of the Polygon2D.
	var static_body: StaticBody2D = StaticBody2D.new()
	var new_collision: CollisionPolygon2D = CollisionPolygon2D.new()
	new_collision.polygon = self.polygon
	static_body.add_child(new_collision)
	self.add_child(static_body)
