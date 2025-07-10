class_name MovingState extends State
## Moving State ##
##This state will choose a random position, from an array of possible positions, and then
##using a navAgent2D make the enemy travel to that position. Upon reaching the desired
##location it will swap to a different state.
##Additionally if we randomly choose the position that we are already at, then it will
##automatically reroll to choose a different target position.


## Variables
@export var enemy: CharacterBody2D
@onready var navAgent: NavigationAgent2D = $"../../NavigationAgent2D"

var next_pos #saveslot for our target position
@export var movement_speed = 400
@onready var allPossiblePositions := [
	$"../../../Test_Tilemap/BossPathPoints/BossPos",
	$"../../../Test_Tilemap/BossPathPoints/BossPos2",
	$"../../../Test_Tilemap/BossPathPoints/BossPos3",
	$"../../../Test_Tilemap/BossPathPoints/BossPos4",
	$"../../../Test_Tilemap/BossPathPoints/BossPos5",
	$"../../../Test_Tilemap/BossPathPoints/BossPos6"
]#positions have been chosen with laser attack in mind


func _ready():
	if not GlobalSignals.phase2_reached.is_connected(phase2Started):
		GlobalSignals.phase2_reached.connect(phase2Started)

#upon entering the state we will choose a location to path to
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

@warning_ignore("unused_parameter")
#every frame the enemy will path towards his target position till he has reached it
#navigation is handled by the Boss' NavigationAgent2D node using our maps NavMesh
func Physics_Update(delta: float):
	
	#if we have a target position
	if next_pos:
		#calculate whats the most ideal movement to reach our destination
		var target_location = next_pos.global_position
		navAgent.target_position = target_location
		
		var current_agent_position = enemy.global_position
		var next_path_position = navAgent.get_next_path_position()
		var new_velocity = current_agent_position.direction_to(next_path_position) * movement_speed 
		
		#upon having reached the next position swap state
		if navAgent.is_navigation_finished():
			swapState()
			return 
		
		if navAgent.avoidance_enabled:
			navAgent.set_velocity(new_velocity)
		else:
			_on_navigation_agent_2d_velocity_computed(new_velocity)


#upon reaching our destination the enemy will stand still
func Exit():
	enemy.velocity = Vector2.ZERO


#velocity setter
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	enemy.velocity = safe_velocity


##method for swapping state, in phase 1 it will always swap to laserattack state
##whilst in phase 2 theres a 25% chance to swap to summon state
func swapState():
	if enemy.phase2:
		var whichState = randf()
		if whichState > 0.25: #75%chance for laser attack
			Transitioned.emit(self, "laserattack")
		else:#25%chance for summon
			Transitioned.emit(self, "summon")
	else:
		#if we're still in phase 1 we'll always swap to laserattack
		Transitioned.emit(self, "laserattack")

func phase2Started():
	movement_speed = 600
