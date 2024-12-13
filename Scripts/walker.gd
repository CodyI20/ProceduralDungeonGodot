extends Node
class_name Walker

const DIRECTIONS = [Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN]

var position := Vector2.ZERO
var direction := Vector2.RIGHT
var borders : Rect2
var step_history := []
var steps_since_turn := 0
var tile_map_layer : TileMapLayer


func _init(starting_pos, new_borders, input_tile_map_layer):
	assert(new_borders.has_point(starting_pos))
	position = starting_pos
	borders = new_borders
	tile_map_layer = input_tile_map_layer

func walk(steps) -> Array:
	create_room(position)
	for step in steps:
		if steps_since_turn >= 3:
			change_direction()
		if step() :
			step_history.append(position)
			tile_map_layer.set_cell(position,0, Vector2i(10,6),0)
		else:
			change_direction()
			
	return step_history
	
func step() -> bool:
	var target_pos = position + direction
	if borders.has_point(target_pos):
		steps_since_turn += 1
		position = target_pos
		return true
	else:
		return false
		
func change_direction() -> void:
	create_room(position)
	steps_since_turn = 0
	var directions = DIRECTIONS.duplicate()
	directions.erase(direction)
	directions.shuffle()
	direction = directions.pop_front()
	while not borders.has_point(position + direction):
		direction = directions.pop_front()

func create_room(position):
	var size = Vector2(randi() % 4 + 2, randi() % 4 + 2)
	var top_left_corner = (position - size/2).ceil()
	for y in size.y:
		for x in size.x:
			var new_step = top_left_corner + Vector2(x,y)
			if borders.has_point(new_step):
				step_history.append(new_step)
