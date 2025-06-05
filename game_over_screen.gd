extends CanvasLayer

#@onready var menu_button_animation = $MainMenuButton/menu_button_animation
@onready var menu_button = $MainMenuButton

# Closes the whole game
func _on_quit_button_pressed() -> void:
	get_tree().quit()

# Loads the main scene which functions as main menu
func _on_main_menu_button_pressed() -> void:
	
	get_tree().change_scene_to_file("res://main.tscn")
	
	

	
	
