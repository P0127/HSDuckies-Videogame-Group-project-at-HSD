extends Area2D
#Consumable that boosts movementspeed
#Is initiated by Item-Manager for Boss Mobs or Trashcans

## VARIABLES
@onready var sound := $AudioStreamPlayer

var effectLength = 3 #in seconds how long effect lasts
var lifetime_length = 15 #in seconds how long until item despawns

## FUNCTIONS
#On initiation: gets drawn, spawns sparkle effect and starts lifetime Timer until despawn
func _ready():
	$Lifetime.wait_time = lifetime_length
	$AnimatedSprite2D.play()
	$CPUParticles2D.set_deferred("emitting", true)
	$Lifetime.start()

#Called by Player Scene on touch
func pickup(player : Node2D):	
	#Calls Player Method to speed up
	player.speed_up(100)
	
	# plays Sound when picked up
	if sound:
		sound.play()
		
	#Starts Globaltimer for effect end
	GlobalSignals.timerSpeedUp.start(effectLength)
	
	#Gets hidden until Animation is finnished, then removed
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite2D/AnimationPlayer.play("collected")

#Only lives for a set amount of time before despawning
func _on_lifetime_timeout():
	#Gets hidden until Animation is finnished, then removed
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite2D/AnimationPlayer.play("lifetime_end")

#Waits for Animation to finnish before removing Instance
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != "drop":
		queue_free()
