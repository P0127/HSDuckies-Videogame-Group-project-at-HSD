extends Node2D # used for spawncheck only right now


func spawncheck(coords: Vector2):
	#check if cell exists
	if ($Boden.get_cell_source_id($Boden.local_to_map(coords)) == -1):
		return false
	
	#if($"Räume".get_cell_source_id($Boden.local_to_map(to_local(coords))) != -1):
		#print("tried to spawn in raum")
		#return false
	#
	#if($Deko.get_cell_source_id($Boden.local_to_map(to_local(coords))) != -1):
		#print("tried to spawn in deko")
		#return false
	
	var tiledata = $Boden.get_cell_tile_data($Boden.local_to_map(to_local(coords)))
	if (tiledata == null):
		return false
	
	var checklayer1 = tiledata.get_navigation_polygon(0)
	if(checklayer1 != null):
		return true
	else:
		return false
	#IT WORKS IM FREEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
