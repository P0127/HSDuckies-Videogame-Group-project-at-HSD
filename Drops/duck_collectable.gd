extends Area2D

@onready var sound := $AudioStreamPlayer

var globalPos
var pitch : float #different for each duck to get variety

func _ready():
	# Starts Animation once
	$DuckPath/DuckPathFollow/AnimatedSprite2D.play("flapping")
	randomize()
	pitch = randf_range(1.1, 1.6)
	GlobalSignals.play_sound.emit("collecting_sound",pitch)

@warning_ignore("unused_parameter")
func _physics_process(delta):
	if ($DuckPath/DuckPathFollow.progress_ratio != 1):
		$DuckPath/DuckPathFollow.progress_ratio += 0.015
		globalPos = $DuckPath/DuckPathFollow/AnimatedSprite2D.global_position
		$CollisionShape2D.global_position = globalPos
		$FeatherExplosion.global_position = globalPos
		$FeatherExplosion2.global_position = globalPos
	else:
		# Ends Animation once path has finnished
		$DuckPath/DuckPathFollow/AnimatedSprite2D.animation = "default"

@warning_ignore("unused_parameter")
func _on_body_entered(body):
	GlobalSignals.duck_collected_signal.emit()#using a global script to get the signal
	#to the hud without requiring it to be a child/parent node 
	GlobalSignals.play_sound.emit("collecting_sound")
		
	$DuckPath/DuckPathFollow/AnimatedSprite2D/AnimationPlayer.play("collected")

@warning_ignore("unused_parameter")
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
