extends Area2D

var effectAmount = 30

func _ready():
	pass 

func pickup(player : Node2D):
	player.heal(effectAmount)
	queue_free()
