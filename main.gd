extends Node

@export var Mob: PackedScene
@export var RangedMob : PackedScene #testing

@onready var MobSpawnTimer = $MobSpawnTimer
@onready var MapFloor = $Test_Tilemap/Boden
@onready var MobSpawningPath = %MobSpawningPath
@onready var Map = $Test_Tilemap


const MOB_LIMIT = 20 #MOB LIMIT
var current_mob_amount = 0 #tracks how many mobs are currently spawned

# Called when the node enters the scene tree for the first time.
func _ready():
	#pass #replace with function if needed
	GlobalSignals.start_game.connect(new_game)
	
	#to prevent the panning over
	$Player.start($StartPosition.position)
	
	# Connect the player's death signal to show game over
	GlobalSignals.game_over.connect(_on_player_died)
	GlobalSignals.reduce_mob_counter.connect(reduce_mob_counter)
	GlobalSignals.game_won.connect(_end_cutscene)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func new_game():
	#needed in case new game is started after game over
	$Player.start($StartPosition.position)
	#moves player to starting position & removed hide()
	spawn_mob()
	$MobSpawnTimer.start()
	#$Player/Path2D.

#Spawns Mobs if Left Mouse Button is clicked at Mouse position
#For Testing
#func _input(event):
	#if event.is_action_pressed("click"):
		##if Mob.can_instantiate():
			##var new_Mob = Mob.instantiate()
			##new_Mob.position = $Player.position + get_viewport().get_mouse_position() - Vector2($StartPosition.position) * 0.8 - Vector2(260,230)
			##add_child(new_Mob)
		#if RangedMob.can_instantiate():
			#var new_Mob = RangedMob.instantiate()
			#new_Mob.position = $Player.position + get_viewport().get_mouse_position() - Vector2($StartPosition.position) * 0.8 - Vector2(260,230)
			#add_child(new_Mob)

#if you spawn multiple mobs at once they will all use same model
func spawn_mob():
	if(current_mob_amount <= MOB_LIMIT):
		var which_mob = randf()
		
		if (which_mob > 0.2): #80% chance for meelee mob 
			var new_mob = preload("res://Mobs/mob.tscn").instantiate()
			MobSpawningPath.progress_ratio = randf() #produces rdm decimal number between 0 & 1
			if(MapFloor.spawncheck(MobSpawningPath.global_position / 3.33)):
				new_mob.global_position = MobSpawningPath.global_position
				add_child(new_mob)
				current_mob_amount += 1
			else:
				spawn_mob() #try again with different position
			
		else: #20% chance for ranged mob
			var new_mob = preload("res://Mobs/ranged_mob.tscn").instantiate()
			MobSpawningPath.progress_ratio = randf() #produces rdm decimal number between 0 & 1
			if(MapFloor.spawncheck(MobSpawningPath.global_position / 3.33)):
				new_mob.global_position = MobSpawningPath.global_position
				add_child(new_mob)
				current_mob_amount += 1
			else:
				spawn_mob()#try again with different position


func _on_mob_spawn_timer_timeout():
	spawn_mob()
	if(MobSpawnTimer.get_wait_time() > 2): #only reduces timer if longer than 2sec 
		MobSpawnTimer.set_wait_time(MobSpawnTimer.get_wait_time() - 0.025)
		
		#every time MobSpawnTimer is dividable by 0.5 increase lvl
		#currently that would be 135 seconds
		#fmod and not % since % only works for int
		if(fmod(MobSpawnTimer.get_wait_time(), 0.5) == 0): 
			GlobalSignals.mob_level_up.emit()

func _on_player_died():
	$GameOver.show()

func _end_cutscene():
	pass


func reduce_mob_counter():
	current_mob_amount -= 1
