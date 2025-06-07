extends Area2D

@onready var sound := $AudioStreamPlayer

var effectLength = 3

func _ready():
	$AnimatedSprite2D.play()

func pickup(player : Node2D):	
	#Calls Player Method to speed up
	player.speed_up(100)
	
	# plays Sound when picked up
	if sound:
		sound.play()
		
	#Starts Globaltimer for effect end
	GlobalSignals.timerSpeedUp.start(effectLength)
	
	$AnimatedSprite2D.set_deferred("visible", false)
	$CollisionShape2D.set_deferred("disabled", true)
	$CPUParticles2D.set_deferred("emitting", false)
	
	# wait until sound is finished 
	if sound:
		await sound.finished
	# wait until particles have particled
	await $CPUParticles2D.finished

	#This Scene is done
	queue_free()
