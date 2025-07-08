extends CanvasLayer

@onready var button_quit_sound_player = $buttonQuit
@onready var button_menu_sound_player = $buttonMenu

## FUNCTIONS MENU BUTTON
func _on_menu_pressed() -> void:
	button_menu_sound_player.play()
	$ControlMenu/Menu/AnimatedMenuButton.play("pressed")
	
	

func _on_animated_menu_button_animation_finished() -> void:
	
	GlobalSignals.scene_controller.remove_scene()
	GlobalSignals.scene_controller.change_gui_scene("res://Hud/startscreen.tscn")


## FUNCTIONS QUIT BUTTON
func _on_quit_pressed() -> void:
	button_quit_sound_player.play()
	$ControlQuit/Quit/AnimatedQuitButton.play("pressed")
	
	

func _on_animated_quit_button_animation_finished() -> void:
	
	get_tree().quit()
