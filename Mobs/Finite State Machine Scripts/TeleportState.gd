class_name TeleportState extends State
## Teleport State ##
##Upon entering this State we will choose a random location out of allPossiblePositions. If we
## already are at that location, then we will choose a different one.
##After having set next_pos to our desired location, our enemy will wait for 2 seconds, after which
## it will slowly lose opacity and fade out over 1 second. Once it is fully seethrough it will 
## teleport to next_pos and slowly over 1 second fade back in there, for a smooth visual process.


## Variables
@export var enemy: CharacterBody2D
@onready var sprite = enemy.get_child(0)

var next_pos
@export var waitBefore : float = 2.0
@export var waitAfter : float = 1.0
@onready var allPossiblePositions := [
	$"../../../Test_Tilemap/BossPathPoints/BossPos",
	$"../../../Test_Tilemap/BossPathPoints/BossPos2",
	$"../../../Test_Tilemap/BossPathPoints/BossPos3",
	$"../../../Test_Tilemap/BossPathPoints/BossPos4",
	$"../../../Test_Tilemap/BossPathPoints/BossPos5",
	$"../../../Test_Tilemap/BossPathPoints/BossPos6"
]

#Enter function of the TeleportState
func Enter():
	#select random point where we will path to
	var indexPos = randi_range(0,5)
	next_pos = allPossiblePositions[indexPos]
	
	#if we are at that position choose a different one
	while next_pos == enemy.last_pos:
		indexPos = randi_range(0,5)
		next_pos = allPossiblePositions[indexPos]
	
	#save chosen position into last_pos for future check
	enemy.last_pos = next_pos
	
	#set waitBefore time to 2seconds
	waitBefore = 2.0
	
	#change sprite
	sprite.animation = "passive"

#update called every frame whilst in the teleport state
func Update(delta: float):
	#set our speed to 0
	enemy.velocity = Vector2()
	
	#check if waitBefore timer is done
	if waitBefore > 0:
		waitBefore -= delta #no -> continue ticking down
	else:
		#yes ->Fade out to 0% opacity over 1 second
		var tween = create_tween()
		tween.tween_property(sprite, "self_modulate:a", 0.0, 1.0)
		
		#then call teleport to swap position
		teleport()
		waitBefore = 500 #not fancy but easiest way to avoid calling teleport() on repeat


#alternative way one could call it: insert key in animation to link to teleport method
#function that teleports the character2D that uses this state
func teleport():
	#wait for fadeout to fully play
	await get_tree().create_timer(1).timeout
	
	#teleport enemy
	enemy.global_position = next_pos.global_position
	
	#play fadein
	var tween = create_tween()
	tween.tween_property(sprite, "self_modulate:a", 1.0, 1.0)
	#Fade out to 100% opacity over 1 second
	
	#wait for fadein to fully play
	await get_tree().create_timer(1).timeout
	swapState()

#method for swapping state, in phase 1 it will always swap to laserattack state
#whilst in phase 2 theres a 30% chance to swap to summon state
func swapState():
	if enemy.phase2:
		var whichState = randf()
		if whichState > 0.3: #70% chance for laser attack
			Transitioned.emit(self, "laserattack")
		else:#30% chance for summon state
			Transitioned.emit(self, "summon")
	else:#if not in phase2 always swaps to laser attack
		Transitioned.emit(self, "laserattack")
