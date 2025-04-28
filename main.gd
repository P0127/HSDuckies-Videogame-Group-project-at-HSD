extends Node

@export var Mob: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready():
	pass #replace with function if needed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func new_game():
	$Player.start($StartPosition.position)
	#moves player to starting position & removed hide()

#Spawns Mobs if Left Mouse Button is clicked at Mouse position
#For Testing
func _input(event):
	if event.is_action_pressed("click"):
		if Mob.can_instantiate():
			var new_Mob = Mob.instantiate()
			new_Mob.position = $Player.position + get_viewport().get_mouse_position() - Vector2($StartPosition.position) * 0.8 - Vector2(260,0)
			add_child(new_Mob)
			
