extends Area2D

var hitpoints = 2 #hits required to destroy and spawn item

func _ready():
	pass 

func take_damage():
	print("ouch")
	$Sprite2D.self_modulate(0,0,0,0)
	hitpoints -= 1
	if hitpoints == 0:
		destroy()

func destroy():
	queue_free()
