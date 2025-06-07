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




#suffering
func spawncheck(coords: Vector2):
	
	#check if cell exists
	if (get_cell_source_id(local_to_map(coords)) == -1):
		return false
	
	#check if 
	#if (raeume.get_cell_source_id(local_to_map(coords)) != -1) or (deko.get_cell_source_id(local_to_map(coords)) != -1):
		#return false
	#
	#
	#var cellCoords = local_to_map(coords)
	#var tiledata = $".".get_cell_tile_data(cellCoords)
	#
	#if(tiledata == null):
		#return false
	#
	#var tile_setvar = tile_set
	#
	#var source_idvar = $".".get_source_id()
	#var tile_atlCoVar = tiledata.get_atlas_coords() #idk if this works
	#
	#var tile_set_source = tile_set.get_source(source_idvar)
	#var navlay = tile_set_source.get_tile_navigation_layers(tile_atlCoVar)
	#
	#if(navlay == 1):
		#return true
	#else:
		#return false
	#
	return true
