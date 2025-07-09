extends Node2D

## Node Variables
@onready var MobSpawnTimer = %MobSpawnTimer
@onready var MapSpawningFloor = $Test_Tilemap/MobSpawnableTiles
@onready var path_2d: Path2D = $Player/Path2D
@onready var MobSpawningPath = %MobSpawningPath
@onready var Map = $Test_Tilemap

## Mob spawning cycle variables
const MOB_LIMIT = 10 #MOB LIMIT
var current_mob_amount = 0 #tracks how many mobs are currently spawned
var natural_spawning_enabled = true #used to disable spawning after boss fight start

# Referenz auf den Dialogue
var dialog_after_pickup_triggered = false		# Flag, um Dialog nur einmal zu starten


# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSignals.play_sound.emit("level_sound")
	#to prevent the panning over
	#moves player to starting position & removed hide()
	$Player.start($StartPosition.position)
	
	#upon starting the game, start the mob spawning cycle
	MobSpawnTimer.start()
	#adjust the mob spawning path to rough edges of users screen
	update_curve_to_screen_edges()

	# Connect the player's death signal to show game over
	GlobalSignals.reduce_mob_counter.connect(reduce_mob_counter)

	GlobalSignals.dialogue_start.connect(_pause_level_on_dialogue_start)
	GlobalSignals.dialogue_finished.connect(_unpause_level_on_dialogue_end)

	GlobalSignals.toggle_natural_spawns.connect(toggle_spawn_cycle)


#This function handels our mob spawns, the param decides how many positions we check
#whilst trying to find a valid spawnpoint.
func spawn_mob(maxAttempts : int):
	#check if there are less mobs than our mob limit currently spawned
	if(current_mob_amount < MOB_LIMIT):
		#generate a random number between 0-1
		var which_mob = randf()
		if (which_mob > 0.2): #80% chance for meelee mob 
			var new_mob = load("res://Mobs/mob.tscn").instantiate()
			#sets the var to a rdm position on its path
			MobSpawningPath.progress_ratio = randf() 
			
			#if that spawn position is within our navmesh -> spawn mob at that position
			if(MapSpawningFloor.spawncheck(MobSpawningPath.global_position)):
				new_mob.global_position = MobSpawningPath.global_position
				add_child(new_mob)
				current_mob_amount += 1
				
			elif(maxAttempts > 0):#do we have more attempts?
				spawn_mob(maxAttempts - 1) #yes -> try again with different position
				# -1 to avoid infinite loop

		else: #20% chance for ranged mob
			var new_mob = load("res://Mobs/ranged_mob.tscn").instantiate()
			#sets the var to a rdm position on its path
			MobSpawningPath.progress_ratio = randf()
			
			#if that spawn position is within our navmesh -> spawn mob at that position
			if(MapSpawningFloor.spawncheck(MobSpawningPath.global_position)):
				new_mob.global_position = MobSpawningPath.global_position
				add_child(new_mob)
				current_mob_amount += 1
				
			elif(maxAttempts > 0):#do we have more attempts?
				spawn_mob(maxAttempts - 1)#yes ->try again with different position
				# -1 to avoid infinite loop 


#function called everytime the MobSpawnTimer times out, initiates a spawn with 4 tries
#additionally it will reduce its own wait time to slowly increase spawns over time
func _on_mob_spawn_timer_timeout():
	var chanceForMultispawn = randf()
	if chanceForMultispawn < 0.1: #10%chance for multispawn
		if natural_spawning_enabled:
			spawn_mob(4)
			spawn_mob(2)
			if(MobSpawnTimer.get_wait_time() > 2): #only reduces timer if longer than 2sec 
				MobSpawnTimer.set_wait_time(MobSpawnTimer.get_wait_time() - 0.025)
	else: #90%chance for single spawn
		if natural_spawning_enabled:
			spawn_mob(4)
			if(MobSpawnTimer.get_wait_time() > 2): #only reduces timer if longer than 2sec 
				MobSpawnTimer.set_wait_time(MobSpawnTimer.get_wait_time() - 0.025)


#function that is called upon a mob being defeated/despawning
func reduce_mob_counter():
	current_mob_amount -= 1

@warning_ignore("unused_parameter")
func _pause_level_on_dialogue_start(dialogueFile : String = ""):
	get_tree().paused = true

func _unpause_level_on_dialogue_end():
	get_tree().paused = false

#function called upon entering scene to set MobSpawningPath to the rough edges
# of the players screen
func update_curve_to_screen_edges():
	#* 5.5 as from testing that gets the best results
	var viewport_size = get_viewport_rect().size * 5.5
	
	#get rid of previous points
	path_2d.curve.clear_points()
	
	var curve_points = [ #since coords are relativ from Path2D this works
		Vector2(-viewport_size.x/2, -viewport_size.y/2), #top left
		Vector2(viewport_size.x/2, -viewport_size.y/2),  #top right
		Vector2(viewport_size.x/2, viewport_size.y/2),   #bot right
		Vector2(-viewport_size.x/2, viewport_size.y/2)   #bot left
	]#/2 as we calc from player position so top left is -1/2,-1/2 instead of 0,0
	
	#add the points to our curve
	for point in curve_points:
		path_2d.curve.add_point(point)
	
	path_2d.curve.add_point(curve_points[0]) #finish loop

#function that is called once the player enters the 2nd floor to disable natural spawns
func toggle_spawn_cycle():
	natural_spawning_enabled = !natural_spawning_enabled



##this is for testing mob stuff simply spawns a mob at mouse click location
##not deleted since could be useful for future team
#@export var Mob: PackedScene
#func _input(event):
	#if event.is_action_pressed("click"):
		#if Mob.can_instantiate():
			#var new_Mob = Mob.instantiate()
			#new_Mob.position = get_global_mouse_position()
			#add_child(new_Mob)
