extends Area2D

var effectLength = 3

func _ready():
	pass

func pickup(player : Node2D):	
	#Calls Player Method to speed up
	player.speed_up(100)
	
	#Starts Globaltimer for effect end
	GlobalSignals.timerSpeedUp.start(effectLength)
	
	#This Scene is done
	queue_free()
