extends Area2D#weapon for RANGED MOBS

#will prob use this later for ranged mobs, just getting some stuff out of the way
#now whilst learning how to do player weapon that shoots in walk direction, instead 
#of how mobs will have to auto focus player

var targets_in_range#saveslot for array of targets/enemies
var current_target#saveslot for current target
@onready var player = $"/root/Main/Player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#targets_in_range = get_overlapping_bodies()
	#
	##if there are targets in range:
	#if targets_in_range.size() > 0:
		##set target to first in array
		#current_target = targets_in_range[0]
	pass




func _on_body_entered(body: Node2D) -> void:
	if body == player:
		look_at(body.global_position)
