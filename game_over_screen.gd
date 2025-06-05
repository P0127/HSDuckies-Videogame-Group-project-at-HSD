extends CanvasLayer


@onready var menu_button = $MainMenuButton
@onready var menu_button_anim = $MenuButtonAnimation

signal game_over
	
func _ready() -> void:
	#$MenuButtonSpriteSheet	.frame = 0 
	 #Show normal button frame
	pass
	
	
	
# Closes the whole game
func _on_quit_button_pressed() -> void:
	get_tree().quit()
	
	
# Loads the main scene which functions as main menu
func _on_main_menu_button_pressed() -> void:
	
	menu_button_anim.play("pressed")
	
	#await menu_button_anim.animation_finished
	await get_tree().create_timer(0.5).timeout
	
	game_over.emit()
	get_tree().change_scene_to_file("res://main.tscn")
	
	

	
	
