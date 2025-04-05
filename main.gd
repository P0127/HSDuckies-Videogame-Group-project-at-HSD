extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass #replace with function if needed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func new_game():
	$Player.start($StartPosition.position)
	#moves player to starting position & removed hide()
