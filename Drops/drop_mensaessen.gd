extends Area2D

@onready var sound := $AudioStreamPlayer

var effectAmount = 30

func _ready():
	$AnimatedSprite2D.play()
	$CPUParticles2D.set_deferred("emitting", true)

func pickup(player : Node2D):
	player.heal(effectAmount)
	
	# plays Sound when picked up
	if sound:
		sound.play()
	
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite2D/AnimationPlayer.play("collected")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
