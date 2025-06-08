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


#boolean method to check if a position is valid for a mob spawn location
#currently mobs still sometimes spawn in walls?
func spawncheck(coords: Vector2):
	
	#check if cell exists
	if (get_cell_source_id(local_to_map(coords)) == -1):
		return false
	
	var tiledata = get_cell_tile_data(local_to_map(to_local(coords)))
	if (tiledata == null):
		return false
	
	var checklayer1 = tiledata.get_navigation_polygon(0)
	if(checklayer1 != null):
		return true
	else:
		return false
