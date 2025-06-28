class_name TeleportState extends State


@export var enemy: CharacterBody2D
@onready var sprite = enemy.get_child(0)

##setup so that we can lazer fire into all hallways
##prob work with set points on the map play animation tp there


##Array of all main Boss Positions
@onready var allPossiblePositions = [
	$"../../../Test_Tilemap/BossPos1",
	$"../../../Test_Tilemap/BossPos2",
	$"../../../Test_Tilemap/BossPos3",
	$"../../../Test_Tilemap/BossPos4"
]
var next_pos
var waitBefore : float = 2.0
var waitAfter : float = 1.0

func Enter():
	##select random point where we will path to
	var indexPos = randi_range(0,3)
	next_pos = allPossiblePositions[indexPos]
	##play animation
	#animation_player.play("teleport")
	#await animation_player.animation_finished
	waitBefore = 2.0
	sprite.animation = "passive"

func Update(delta: float):
	if waitBefore > 0:
		waitBefore -= delta
	else:
		teleport()

##insert key in animation to link to teleport method
func teleport():
	enemy.global_position = next_pos.global_position
	Transitioned.emit(self, "laserattack")

func Exit():
	print("teleport state exit called")
