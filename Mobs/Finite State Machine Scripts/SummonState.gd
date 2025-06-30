class_name SummonState extends State


@export var enemy: CharacterBody2D
#var summon = load("res://Mobs/mob.tscn").instantiate()

#ideas: if not attacked for 10hp within 2.5sec it goes through
#if it takes x dmg within y time it swaps state to tp away
##maybe set summon chargeup to 2.5 on enter ++save current health into enter health
##count up each frame ++ check if enter health and current health are too far apart
##check if positions left below and right are valid spawns
##spawn summons THAT DONT DROP DUCKS maybe with a static var in mobs that decides if they drop or not
##mob method to change them dropping +prob tied into map swap if 2nd floor only unlock after collecting pre final duck

#need a reference to the tilemaplayer from which we wanna check if spawnable
@onready var navLayer = $"../../../Test_Tilemap/Boden"
#which spots do we want to summon em on? -> prob left/right meelee(2x spawn) + below/above ranged(1x spawn)
var directions = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
#variable to save entry health in so that summon is interuptable
var entry_health
#value for how much dmg is required to cancel the summon
@export var damage_required = 10

func Enter():
	#stand still
	enemy.velocity = Vector2()
	#save health from time of entering the state
	entry_health = enemy.health

func Update(delta: float):
	if entry_health - enemy.health >= damage_required:
		Transitioned.emit(self, "teleport")
