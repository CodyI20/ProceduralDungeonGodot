extends Node2D

var borders := Rect2(1,1,38,21)
@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var generate_dugeon: Button = $CanvasLayer/UI/GenerateDugeon

func _ready() -> void:
	generate_dugeon.pressed.connect(generate_level)
	generate_level()
	
func generate_level() -> void:
	tile_map_layer.clear()
	var walker = Walker.new(Vector2(19, 11), borders)
	var map = walker.walk(500) # TWEAKABLE
	
	walker.queue_free()
	
	for location in map:
		tile_map_layer.set_cell(location,0, Vector2i(10,6),0)
	
