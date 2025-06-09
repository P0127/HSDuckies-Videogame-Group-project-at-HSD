extends Node2D # used for spawncheck only right now


#-1 output = invalid spawnpoint
#0 output = very close to edge reset position in tile
#1 output = position okay 
func spawncheck(coords: Vector2):
	#check if cell exists
	if ($Boden.get_cell_source_id($Boden.local_to_map(coords)) == -1):
		return -1
	
	var tiledata = $Boden.get_cell_tile_data($Boden.local_to_map(to_local(coords)))
	if (tiledata == null):
		return -1
	
	var checklayer1 = tiledata.get_navigation_polygon(0)
	if(checklayer1 != null):
		#need to split this inner up
		if(fmod(coords.x, 40) <= 10 or fmod(coords.x, 40) >= 30):
			return 0
		if(fmod(coords.y, 40) <= 10 or fmod(coords.y, 40) >= 30):
			return 0
		return 1
	else:
		return -1
	#IT WORKS IM FREEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
