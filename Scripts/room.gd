extends RigidBody2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
var size

func make_room(_pos, _size):
	position = _pos
	size = _size
	var s = RectangleShape2D.new()
	s.extents = size
	collision_shape_2d.shape = s
