extends Area2D

@onready var sound := $AudioStreamPlayer


var effectLength = 3

func _ready():
	pass

func pickup(player : Node2D):	
	#Calls Player Method to speed up
	player.speed_up(100)
	
	# plays Sound when picked up
	if sound:
		sound.play()
		
	#Starts Globaltimer for effect end
	GlobalSignals.timerSpeedUp.start(effectLength)
	
	# wait until sound is finished 
	if sound:
		await sound.finished

	#This Scene is done
	queue_free()
