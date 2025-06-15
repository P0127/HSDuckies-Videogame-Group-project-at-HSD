extends Area2D

@onready var sound := $AudioStreamPlayer

var effectChangeAmount = 2 #Halves Time needed to shoot
var effectLength = 5

func _ready():
	$AnimatedSprite2D.play()
	$CPUParticles2D.set_deferred("emitting", true)
	$Lifetime.start()

func pickup(player : Node2D):
	#Calls Player Method to change weapon firerate
	player.increase_firerate(effectChangeAmount)
	
	# plays Sound when picked up
	if sound:
		sound.play()
		
	#Starts Globaltimer for effect end
	GlobalSignals.timerFirerate.start(effectLength)
	
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite2D/AnimationPlayer.play("collected")
	
	# Get reference to the global scene controller
	var scene_controller = GlobalSignals.scene_controller
	
	# Check if the scene controller and current scene are valid
	if scene_controller and scene_controller.current_scene:
		var current_scene = scene_controller.current_scene
	
		# Trigger the dialog only if it hasn't been triggered yet
		if not current_scene.dialog_after_pickup_triggered:
			current_scene.dialog_after_pickup_triggered = true
		
		# Check if the node "Dialogue_begin" exists in the scene
		if current_scene.has_node("Dialogue_begin"):
			var dialogue = current_scene.get_node("Dialogue_begin")
			
			# Set the dialogue file and start the dialogue
			dialogue.d_file = "res://Dialogue_cutscenes/ZwischenDialog_1.json"
			dialogue.start()
		else:
			print("DEBUG: Dialogue_begin Node nicht gefunden in current_scene")
	else:
		print("DEBUG: Scene_Controller oder current_scene nicht verfügbar")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != "drop":
		queue_free()


func _on_lifetime_timeout():
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite2D/AnimationPlayer.play("lifetime_end")
