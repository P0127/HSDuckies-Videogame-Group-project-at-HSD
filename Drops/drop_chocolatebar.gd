extends Area2D

var effectChangeAmount = 2 #Halves Time needed to shoot
var effectLength = 5

func _ready():
	pass 

func pickup(player : Node2D):
	#Calls Player Method to change weapon firerate
	player.increase_firerate(effectChangeAmount)
	
	#Starts Globaltimer for effect end
	GlobalSignals.timerFirerate.start(effectLength)
	
	#This Scene is done
	queue_free()
