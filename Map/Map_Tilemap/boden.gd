extends TileMapLayer

@onready var raeume: TileMapLayer = $"../Räume"
@onready var deko: TileMapLayer = $"../Deko"

# check if coordinates are in the specific TileMapLayer
func _use_tile_data_runtime_update(coords):
	if (coords in raeume.get_used_cells()) or (coords in deko.get_used_cells()):
		return true
	return false

# check each tile itself. using coordinates or tile-data and set navigation on null 
func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData):
	if (coords in raeume.get_used_cells()) or (coords in deko.get_used_cells()):
		tile_data.set_navigation_polygon(0, null)
