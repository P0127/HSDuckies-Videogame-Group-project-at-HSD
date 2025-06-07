extends Area2D

@onready var sound := $AudioStreamPlayer

var effectAmount = 30

func _ready():
	$AnimatedSprite2D.play()

func pickup(player : Node2D):
	player.heal(effectAmount)
	
	# plays Sound when picked up
	if sound:
		sound.play()
	
	$AnimatedSprite2D.set_deferred("visible", false)
	$CollisionShape2D.set_deferred("disabled", true)
	$CPUParticles2D.set_deferred("emitting", false)
	
	# wait until sound is finished 
	if sound:
		await sound.finished
	# wait until particles have particled
	await $CPUParticles2D.finished
	
	queue_free()
