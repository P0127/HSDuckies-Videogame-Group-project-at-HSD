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
