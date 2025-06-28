class_name MovingState extends State


@export var enemy: CharacterBody2D
@export var map: TileMapLayer
@onready var navAgent: NavigationAgent2D = $"../../NavigationAgent2D"

##Array of all main Boss Positions
@onready var allPossiblePositions = [
	$"../../../Test_Tilemap/BossPos1",
	$"../../../Test_Tilemap/BossPos2",
	$"../../../Test_Tilemap/BossPos3",
	$"../../../Test_Tilemap/BossPos4"
]

var next_pos
var movement_speed = 200

##have setpoints on the map and use navagent2d alongside a navmesh to make him path between the points
##prob have the points saved in an array then choose a rdm index and path to that point
## dont think theres a need for a close point path only rule
##

func Enter():
	##select random point where we will path to
	var indexPos = randi_range(0,3)
	next_pos = allPossiblePositions[indexPos]

func Physics_Update(delta: float):
	enemy.velocity = Vector2.ZERO
	#target_homing is the Player Node (checked in Signals) and calls on Player Position
	if next_pos:
		var target_location = next_pos.global_position
		navAgent.target_position = target_location
		
		var current_agent_position = enemy.global_position
		var next_path_position = navAgent.get_next_path_position()
		var new_velocity = current_agent_position.direction_to(next_path_position) * movement_speed
		
		if navAgent.is_navigation_finished():
			Transitioned.emit(self, "attack")
			#return 
			#prob some transition to lazer attack state
		
		if navAgent.avoidance_enabled:
			navAgent.set_velocity(new_velocity)
		else:
			_on_navigation_agent_2d_velocity_computed(new_velocity)
##we dont need move_and_slide() here since we call it in the Char2D script

func Exit():
	enemy.velocity = Vector2.ZERO

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	enemy.velocity = safe_velocity
