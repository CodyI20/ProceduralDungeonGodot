extends Node2D

const ROOM = preload("res://Scenes/room.tscn")
@onready var map: TileMapLayer = $TileMapLayer
@onready var generate_dugeon: Button = $CanvasLayer/UI/GenerateDugeon

@export var rooms_container : Node2D


@export var tileSize = 32
@export var numberOfRooms = 50
@export var minSize = 4
@export var maxSize = 10
@export var horizontalSpread = 0
@export var cull = 0.2

var path # A* pathfiunding object

func _ready():
	if rooms_container == null:
		printerr("THE CONTAINER OF THE ROOMS IS NOT ASSIGNED!")
		return
	randomize()
	generate_dugeon.pressed.connect(make_many_rooms)
	make_many_rooms()

func make_many_rooms():
	for room in rooms_container.get_children():
		room.queue_free()
	path = null
	for i in range(numberOfRooms):
		var startPosition = Vector2(randf_range(-horizontalSpread, horizontalSpread), 0)
		var newRoom = ROOM.instantiate()
		rooms_container.add_child(newRoom)
		var width = minSize + randi() % (maxSize - minSize)
		var height = minSize + randi() % (maxSize - minSize)
		newRoom.make_room(startPosition, Vector2(width, height) * tileSize)
	#wait for the rooms to spread
	await get_tree().create_timer(1.1).timeout
	#cull rooms
	var roomPositions = []
	for room in rooms_container.get_children():
		if randf() < cull:
			room.queue_free()
		else:
			room.freeze = true
			roomPositions.append(Vector2(room.position.x, room.position.y))
	await get_tree().process_frame
	#generate a MST
	path = find_mst(roomPositions)

func _draw():
	for room in rooms_container.get_children():
		draw_rect(Rect2(room.position - room.size, room.size * 2), Color(0, 1, 0, 1), false)
	if path:
		for p in path.get_point_ids():
			for c in path.get_point_connections(p):
				var pp = path.get_point_position(p)
				var cp = path.get_point_position(c)
				draw_line(Vector2(pp.x, pp.y), Vector2(cp.x, cp.y), Color(1, 1, 0, 1), 15, true)

func _process(delta):
	queue_redraw()

func _input(event):
	if event.is_action_pressed("ui_select"):
		for n in rooms_container.get_children():
			n.queue_free()
		path = null
		make_many_rooms()
	if event.is_action_pressed('ui_focus_next'):
		make_map()

func find_mst(nodes):
	#Prim's algorithm
	path = AStar2D.new()
	path.add_point(path.get_available_point_id(), nodes.pop_front())
	
	#repeat until no more node remains
	while nodes:
		var minD = INF #minimum distance so far
		var minP = null #position of that node
		var p = null #current position
		#loop through all points in the path
		for p1 in path.get_point_ids():
			var p3
			p3 = path.get_point_position(p1)
			#loop though the remaining nodes
			for p2 in nodes:
				if p3.distance_to(p2) < minD:
					minD = p3.distance_to(p2)
					minP = p2
					p = p3
		var n = path.get_available_point_id()
		path.add_point(n, minP)
		path.connect_points(path.get_closest_point(p), n)
		nodes.erase(minP)
	return path

func make_map():
	#created tilemap from rooms and path
	map.clear()
	
	#fill tielemap with walls and then carve with empty rooms
	var fullRectangle = Rect2()
	for room in rooms_container.get_children():
		var r = Rect2(room.position - room.size, room.get_node("CollisionShape2D").shape.extents * 2)
		fullRectangle = fullRectangle.merge(r)
	var topLeft = map.local_to_map(fullRectangle.position)
	var bottomRight = map.local_to_map(fullRectangle.end)
	for x in range(topLeft.x, bottomRight.x):
		for y in range(topLeft.y, bottomRight.y):
			map.set_cell(Vector2i(x, y), 0, Vector2i(10,6))
	#carve the rooms
	var corridors = [] #one corridor per connection
	for room in rooms_container.get_children():
		var s = (room.size / tileSize).floor()
		var pos = map.local_to_map(room.position)
		var ul = (room.position / tileSize).floor() - s
		for x in range(2, s.x * 2 - 1):
			for y in range(2, s.y * 2 - 1):
				map.set_cell(Vector2i(ul.x + x, ul.y + y), 0, Vector2i(4, 2)) 
		#carve the connection
		var p = path.get_closest_point(Vector2(room.position.x, room.position.y))
		for conn in path.get_point_connections(p):
			if not conn in corridors:
				var start = map.local_to_map(Vector2(path.get_point_position(p).x, path.get_point_position(p).y))
				var end = map.local_to_map(Vector2(path.get_point_position(conn).x, path.get_point_position(conn).y))
				carve_path(start, end)
			corridors.append(p)

func carve_path(pos1, pos2):
	#carve a pth between two points
	var xDiff = sign(pos2.x - pos1.x)
	var yDiff = sign(pos2.y - pos1.y)
	if xDiff == 0:
		xDiff = pow(-1.0, randi() % 2)
	if yDiff == 0:
		yDiff = pow(-1.0, randi() % 2)
	#choose either x and then y or y and then x
	var xY = pos1
	var yX = pos2
	if(randi() % 2) > 0:
		xY = pos2
		yX = pos1
	for x in range(pos1.x, pos2.x, xDiff):
		map.set_cell(Vector2i(x, xY.y), 0, Vector2i(4, 2))
		map.set_cell(Vector2i(x, xY.y + yDiff), 0, Vector2i(4, 2)) #widen the corridors
	for y in range(pos1.y, pos2.y, yDiff):
		map.set_cell(Vector2i(yX.x, y), 0, Vector2i(4, 2))
		map.set_cell(Vector2i(yX.x + xDiff, y), 0, Vector2i(4, 2)) #widen the corridors
