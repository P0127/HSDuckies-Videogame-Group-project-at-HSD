extends CanvasLayer

## NODE NAMES
@onready var start_button = $StartButton
@onready var start_button_animation = $StartButton/StartButtonAnimations
@onready var button_sound_player = $AudioStreamPlayer
@onready var background_pic = $background
@onready var duck = $duck
@onready var duck_anim = $duck/AnimationPlayer
@onready var shine = $ShineScaled
@onready var shine_anim = $ShineScaled/bling


## FUNCTIONS 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	duck_anim.play("duckie")
	shine_anim.play("bling")

	# Signal verbinden
	#dialogue_node.connect("dialog_finished", Callable(self, "_on_dialog_finished"))  

#Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass

func _on_start_button_pressed():
	# plays pressed animation
	start_button_animation.play("pressed")
	
	# plays button sound when pressed 
	button_sound_player.play()
	
	#Once Signal is finnished, start_game!
	
	# Start the dialog with the path to your JSON file
	#dialogue_node.start("res://Dialogue_cutscenes/dialog_anfang.json")  

func _on_start_button_animations_animation_finished() -> void:
	#signals the scene controller to switch to main game and to ingame hud
	GlobalSignals.scene_controller.change_game_scene("res://level_1.tscn")
	GlobalSignals.scene_controller.change_gui_scene("res://Hud/ingame.tscn")
