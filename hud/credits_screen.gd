extends CanvasLayer
@onready var back_b_anim = $BackButton/AnimatedSprite2D



func _ready() -> void:
	#sets up the URL links, connecting them to a prewritten godot signal and the _on_meta_clicked function
	$VScrollBar/creditsText.meta_clicked.connect(_on_meta_clicked)
	
func _on_meta_clicked(meta):
	#allows the system to open URL links when clicked
	OS.shell_open(meta)

	

func _on_back_button_pressed() -> void:
	#plays pressed animation for back button
	back_b_anim.play("pressed")
	


func _on_animated_sprite_2d_animation_finished() -> void:
	#signals the scene controller to switch to start screen and to remove the current scene(credits)
	GlobalSignals.scene_controller.remove_scene()
	GlobalSignals.scene_controller.change_gui_scene("res://Hud/startscreen.tscn")
