extends TileMapLayer


#this is what checks if a mob is allowed to spawn here
func spawncheck(coords: Vector2):
	if (local_to_map(to_local(coords)) in get_used_cells()):
		return true
	return false
