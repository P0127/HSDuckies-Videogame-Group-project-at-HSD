extends Area2D

@onready var soundChocolatebar := $AudioStreamPlayer

var effectChangeAmount = 2 #Halves Time needed to shoot
var effectLength = 5

func _ready():
	pass 

func pickup(player : Node2D):
	#Calls Player Method to change weapon firerate
	player.increase_firerate(effectChangeAmount)
	
	# plays Sound when picked up
	if soundChocolatebar:
		soundChocolatebar.play()
		
	#Starts Globaltimer for effect end
	GlobalSignals.timerFirerate.start(effectLength)
	
	# wait until sound is finished 
	if soundChocolatebar:
		await soundChocolatebar.finished
	
	#This Scene is done
	queue_free()
