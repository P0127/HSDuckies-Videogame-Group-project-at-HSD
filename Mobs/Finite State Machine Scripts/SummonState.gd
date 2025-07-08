class_name SummonState extends State
## Summon State ##
##Upon entering this State we will save the Boss' current health in a variable. Then we rotate
## the spawnpoints around the enemy to face the player, afterwards IF the player didnt do enough
## damage to interrupt the summoning, 2 Meelee Mobs and 1 Ranged Mob will spawn between the Boss
## and the Player. These Summoned mobs will slowly appear and start with 0 speed, scaling up over
## the course of 2 seconds. 
##Summoned Mobs dont drop ducks and instead have a chance to drop piece of healing loot for the 
## Player to recover with. Summoned Mobs are not immune to the Boss' attacks.
##If the Player does deal enough damage to interrupt the summoning, then no Mobs will be spawned
## and the Boss will teleport away, else the Boss will randomly choose a movement State to swap
## to after a successfull summon.


## Variables
@export var enemy: CharacterBody2D
#need a reference to the tilemaplayer from which we wanna check if spawnable
@onready var navLayer = $"../../../Test_Tilemap/MobSpawnableTiles"
#variable to save entry health in so that summon is interuptable
var entry_health
#value for how much dmg is required to cancel the summon
@export var damage_required = 10
#maybe help variable to cancel
var cancel: bool

#Spawnpoints NEEDS to be a child of enemy, else it doesnt track positions correctly
@onready var individual_spawn_positions = [
	$"../../Spawnpoints/Left",
	$"../../Spawnpoints/Center",
	$"../../Spawnpoints/Right"
]
@onready var spawnpoints: Node2D = $"../../Spawnpoints"
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")

#upon entering this state our enemy will stand still and save its own current hp in entry_health.
#Then it will align the summon positions to be pointed toward the players position, before finally
#summoning its supporting mobs
func Enter():
	#stand still
	enemy.velocity = Vector2()
	#save health from time of entering the state
	entry_health = enemy.health
	
	cancel = false
	#make summon positions face player
	realign_positions()
	#summon
	summonMobs()

#check each frame if enemy has taken more damage than allowed
func Update(delta: float):
	if entry_health - enemy.health >= damage_required:
		cancel = true #set flag to interrupt summoning
		Transitioned.emit(self, "teleport") #too much dmg taken so teleport away

#this function checks which of the 4 cardinal directions makes the spawn locations be closest
# to the player and then sets them to that rotation, this way mobs are spawned between the
# player and the boss.
func realign_positions():
	#variables
	var lowest_distance = 999999999
	var direction
	var best_rotation
	
	#check North,East,South,West
	for i in range(0, 360, 90):
		spawnpoints.rotation = i
		direction = player.global_position - individual_spawn_positions[1].global_position
		
		#if the distance to the player is less than previous lowest distance update lowest distance
		if direction.length() < lowest_distance:
			lowest_distance = direction.length()
			best_rotation = i
	
	#after trying all directions set the rotation to what yielded the best results
	spawnpoints.rotation = best_rotation

#This function waits 5 seconds as a channelling time, then it checks if the cancel flag has been
# activated, if yes the summoning has been interrupted and no mobs are spawned due to the player
# having dealt enough damage to us in a short time.
#Else we will summon 2 meelee and 1 ranged mob that will slowly fade in and gain speed towards
# the player. Mobs are only summoned as long as the spawnlocation is on navigatable terrain.
#Afterwards the enemy will swap to a different state.
func summonMobs():
	#wait 5 seconds
	await get_tree().create_timer(5).timeout
	
	#if player did enough damage stop the summoning
	if cancel:
		#print("cancel tracked and summon cancelled!")
		return
	
	var meelee1 = load("res://Mobs/mob.tscn").instantiate()
	var meelee2 = load("res://Mobs/mob.tscn").instantiate()
	var ranged = load("res://Mobs/ranged_mob.tscn").instantiate()
	
	if(navLayer.spawncheck(individual_spawn_positions[0].global_position)):
		meelee1.summoned()
		meelee1.global_position = individual_spawn_positions[0].global_position
		enemy.add_sibling(meelee1)
	
	if(navLayer.spawncheck(individual_spawn_positions[1].global_position)):
		ranged.summoned()
		ranged.global_position = individual_spawn_positions[1].global_position
		enemy.add_sibling(ranged)
	
	if(navLayer.spawncheck(individual_spawn_positions[2].global_position)):
		meelee2.summoned()
		meelee2.global_position = individual_spawn_positions[2].global_position
		enemy.add_sibling(meelee2)
	
	#swap to a movement option state
	swapState()


#function to swap to either moving or teleport state
func swapState():
	#dont need phase 2 check as summon state is only entered if we are in phase2
	var swapTo = randf()
	if(swapTo > 0.6):#40% chance for moving state
		Transitioned.emit(self, "moving")
	else:#60% chance for teleport state
		Transitioned.emit(self, "teleport")
	
