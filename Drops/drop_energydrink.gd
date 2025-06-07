extends Area2D

@onready var sound := $AudioStreamPlayer

var effectLength = 3

func _ready():
	$AnimatedSprite2D.play()
	$CPUParticles2D.set_deferred("emitting", true)
	

func pickup(player : Node2D):	
	#Calls Player Method to speed up
	player.speed_up(100)
	
	# plays Sound when picked up
	if sound:
		sound.play()
		
	#Starts Globaltimer for effect end
	GlobalSignals.timerSpeedUp.start(effectLength)
	
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite2D/AnimationPlayer.play("collected")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "collected":
		queue_free()
