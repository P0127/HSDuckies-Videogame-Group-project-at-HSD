extends Area2D


func _ready():
	pass 

func pickup(player : Node2D):
	print("MENSA METHOD")
	player.heal(30.0)
	queue_free()
