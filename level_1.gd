extends Node2D

@export var Mob: PackedScene
@export var RangedMob : PackedScene #testing

@onready var MobSpawnTimer = %MobSpawnTimer
@onready var MapSpawningFloor = $Test_Tilemap/MobSpawnableTiles
@onready var MobSpawningPath = %MobSpawningPath
@onready var Map = $Test_Tilemap


const MOB_LIMIT = 20 #MOB LIMIT
var current_mob_amount = 0 #tracks how many mobs are currently spawned

# Called when the node enters the scene tree for the first time.
func _ready():
	#to prevent the panning over
	#moves player to starting position & removed hide()
	$Player.start($StartPosition.position)
	
	#spawn_mob(5)
	MobSpawnTimer.start()
	#$Player/Path2D.
	
	# Connect the player's death signal to show game over
	GlobalSignals.reduce_mob_counter.connect(reduce_mob_counter)
	
	update_curve_to_screen_edges()
	#couldnt find a better way of getting the Path2D to our screen edges so this will do for now
	#will prob look more into it after TDOT


#Spawns Mobs if Left Mouse Button is clicked at Mouse position
#For Testing
#func _input(event):
	#if event.is_action_pressed("click"):
		#if Mob.can_instantiate():
			#var new_Mob = Mob.instantiate()
			#new_Mob.position = $Player.position + get_viewport().get_mouse_position() - Vector2($StartPosition.position) * 0.8 - Vector2(260,230)
			#add_child(new_Mob)
		#if RangedMob.can_instantiate():
			#var new_Mob = RangedMob.instantiate()
			#new_Mob.position = $Player.position + get_viewport().get_mouse_position() - Vector2($StartPosition.position) * 0.8 - Vector2(260,230)
			#add_child(new_Mob)

#if you spawn multiple mobs at once they will all use same model
func spawn_mob(maxAttempts : int):
	if(current_mob_amount <= MOB_LIMIT):
		var which_mob = randf()
		if (which_mob > 0.2): #80% chance for meelee mob 
			var new_mob = load("res://Mobs/mob.tscn").instantiate()
			MobSpawningPath.progress_ratio = randf() #produces rdm decimal number between 0 & 1
			if(MapSpawningFloor.spawncheck(MobSpawningPath.global_position)):
				new_mob.global_position = MobSpawningPath.global_position
				#print("spawn mob", new_mob)
				add_child(new_mob)
				current_mob_amount += 1
			elif(maxAttempts > 0):
				spawn_mob(maxAttempts - 1) #try again with different position
			
		else: #20% chance for ranged mob
			var new_mob = load("res://Mobs/ranged_mob.tscn").instantiate()
			MobSpawningPath.progress_ratio = randf() #produces rdm decimal number between 0 & 1
			if(MapSpawningFloor.spawncheck(MobSpawningPath.global_position)):
				new_mob.global_position = MobSpawningPath.global_position
				#print("spawn mob", new_mob)
				add_child(new_mob)
				current_mob_amount += 1
			elif(maxAttempts > 0):
				spawn_mob(maxAttempts - 1)#try again with different position


func _on_mob_spawn_timer_timeout():
	spawn_mob(5)
	if(MobSpawnTimer.get_wait_time() > 2): #only reduces timer if longer than 2sec 
		MobSpawnTimer.set_wait_time(MobSpawnTimer.get_wait_time() - 0.025)
		
		#every time MobSpawnTimer is dividable by 0.5 increase lvl
		#currently that would be 135 seconds
		#fmod and not % since % only works for int
		if(fmod(MobSpawnTimer.get_wait_time(), 0.5) == 0): 
			GlobalSignals.mob_level_up.emit()


func reduce_mob_counter():
	current_mob_amount -= 1


func update_curve_to_screen_edges():
	var viewport_size = get_viewport_rect().size * 5.5
	#print("VIEWPORT SIZE X = ", viewport_size.x)
	#print("VIEWPORT SIZE Y = ", viewport_size.y)
	
	$Player/Path2D.curve.clear_points()
	
	#v2
	var curve_points = [ #since coords are relativ from Path2D this works
		Vector2(-viewport_size.x/2, -viewport_size.y/2), #top left
		Vector2(viewport_size.x/2, -viewport_size.y/2),  #top right
		Vector2(viewport_size.x/2, viewport_size.y/2),   #bot right
		Vector2(-viewport_size.x/2, viewport_size.y/2)   #bot left
	]
	for point in curve_points:
		$Player/Path2D.curve.add_point(point)
	
	$Player/Path2D.curve.add_point(curve_points[0]) #finish loop
