extends Area2D

@onready var sound := $AudioStreamPlayer

var effectAmount = 30

func _ready():
	$AnimatedSprite2D.play()
	$CPUParticles2D.set_deferred("emitting", true)
	$Lifetime.start()

func pickup(player : Node2D):
	player.heal(effectAmount)
	
	# plays Sound when picked up
	if sound:
		sound.play()
	
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite2D/AnimationPlayer.play("collected")
	
	var scene_controller = GlobalSignals.scene_controller
	if scene_controller and scene_controller.current_scene:
		var current_scene = scene_controller.current_scene
	
		if not current_scene.dialog_after_pickup_triggered:
			current_scene.dialog_after_pickup_triggered = true
		
		if current_scene.has_node("Dialogue_begin"):
			var dialogue = current_scene.get_node("Dialogue_begin")
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
