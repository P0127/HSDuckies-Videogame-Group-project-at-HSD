extends TileMapLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#boolean method to check if a position is valid for a mob spawn location
#from a previous attempt will remove later once certain not needed anymore
func spawncheck2(coords: Vector2):
	#check if cell exists
	if (get_cell_source_id(local_to_map(coords)) == -1):
		print("cell doesnt exist spawningerror")
		return false
	
	var tiledata = get_cell_tile_data(local_to_map(coords))
	if (tiledata == null):
		print("tiledata doesnt exist spawningerror")
		return false
	
	var checklayer2 = tiledata.get_navigation_polygon(1)
	if(checklayer2 != null):
		return true
	else:
		print("navdata doesnt exist spawningerror")
		return false

#new attempt
func spawncheck(coords: Vector2):
	if (local_to_map(to_local(coords)) in get_used_cells()):
		return true
	return false
