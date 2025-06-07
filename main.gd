extends Node

@export var Mob: PackedScene
@export var RangedMob : PackedScene #testing

@onready var MobSpawnTimer = $MobSpawnTimer
@onready var MapFloor = $Test_Tilemap/Boden
@onready var MobSpawningPath = %MobSpawningPath
@onready var Map = $Test_Tilemap


const MOB_LIMIT = 5 #MOB LIMIT
var current_mob_amount = 0 #tracks how many mobs are currently spawned

# Called when the node enters the scene tree for the first time.
func _ready():
	#pass #replace with function if needed
	$Hud.start_game.connect(new_game)
	var trashcan = preload("res://Destroyable/destroyable_trashcan.tscn").instantiate()
	trashcan.global_position = Vector2(2000,2400)
	add_child(trashcan)
	# Connect the player's death signal to show game over
	$Player.health_death.connect(_on_player_died)
	GlobalSignals.reduce_mob_counter.connect(reduce_mob_counter)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func new_game():
	$Player.start($StartPosition.position)
	#moves player to starting position & removed hide()
	spawn_mob()
	$MobSpawnTimer.start()

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
	var which_mob = randf()
	if(current_mob_amount <= MOB_LIMIT):
		if (which_mob > 0.2): #80% chance for meelee mob
			var new_mob = preload("res://Mobs/mob.tscn").instantiate()
			MobSpawningPath.progress_ratio = randf() #produces rdm decimal number between 0 & 1
			#if(MapFloor.get_cell_source_id(MapFloor.local_to_map(MobSpawningPath.global_position / 3.33)) == 4 and MapFloor.local_to_map(MobSpawningPath.global_position) not in $Test_Tilemap/Räume.get_used_cells()):
			#if(MapFloor.get_cell_source_id(MapFloor.local_to_map(MobSpawningPath.global_position / 3.33)) == 4):
			if(Map.spawncheck(MobSpawningPath.global_position / 3.33)):
				new_mob.global_position = MobSpawningPath.global_position
				add_child(new_mob)
				current_mob_amount += 1
			else:
				#below line from testing
				print("meelee")
				print($Test_Tilemap/Boden.get_cell_source_id($Test_Tilemap/Boden.local_to_map(MobSpawningPath.global_position)))
				print(MapFloor.local_to_map(MobSpawningPath.global_position))
				spawn_mob()
		else: #20% chance for ranged mob
			var new_mob = preload("res://Mobs/ranged_mob.tscn").instantiate()
			MobSpawningPath.progress_ratio = randf() #produces rdm decimal number between 0 & 1
			#if(MapFloor.get_cell_source_id(MapFloor.local_to_map(MobSpawningPath.global_position / 3.33)) == 4):
			if(Map.spawncheck(MobSpawningPath.global_position / 3.33)):
				new_mob.global_position = MobSpawningPath.global_position
				add_child(new_mob)
				current_mob_amount += 1
			else:
				spawn_mob()
				print("ranged:")
				print(MapFloor.get_cell_source_id(MobSpawningPath.global_position)) #testing


func _on_mob_spawn_timer_timeout():
	spawn_mob()
	if(MobSpawnTimer.get_wait_time() > 2): #only reduces timer if longer than 2sec to not spawn wayyyy too many mobs
		MobSpawnTimer.set_wait_time(MobSpawnTimer.get_wait_time() - 0.0025)
		#print(MobSpawnTimer.get_wait_time()) #testing to make sure it works correctly

func _on_player_died():
	$GameOver.show()


#big range around player used for despawning
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("all_mobs"):
		body.queue_free()
		current_mob_amount -= 1

func reduce_mob_counter():
	current_mob_amount -= 1
