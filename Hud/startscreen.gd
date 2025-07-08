extends CanvasLayer

## NODE NAMES
@onready var start_button = $ControlStartButton/StartButton
@onready var start_button_animation = $ControlStartButton/StartButton/StartButtonAnimations
@onready var background_pic = $ControlBG
@onready var duck = $ControlDuck/duck
@onready var duck_anim = $ControlDuck/duck/AnimationPlayer
@onready var shine_anim = $"ContainerTitle+Bling/ShineScaled/bling"
@onready var credits_button = $ControlCreditB/CreditButton
@onready var credits_button_anim = $ControlCreditB/CreditButton/AnimatedCreditB

@onready var quit_button_start= $QuitButtonOnstart
@onready var quit_button_start_anim = $QuitButtonOnstart/AnimatedSprite2D
@onready var background_music = $backgroundMusicStart
@onready var button_quit_sound = $buttonQuitS
@onready var button_credit_sound = $buttonCredits

## FUNCTIONS 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	duck_anim.play("duckie")
	shine_anim.play("bling")
	background_music.play()
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
	GlobalSignals.play_sound.emit("starting_sound")
	
	#Once Signal is finnished, start_game!
	
	# Start the dialog with the path to your JSON file
	#dialogue_node.start("res://Dialogue_cutscenes/dialog_anfang.json")  

func _on_start_button_animations_animation_finished() -> void:
	#signals the scene controller to switch to main game and to ingame hud
	GlobalSignals.scene_controller.change_game_scene("res://level_1.tscn")
	GlobalSignals.scene_controller.change_gui_scene("res://Hud/ingame.tscn")
	background_music.stop()
	
func _on_credit_button_pressed() -> void:
	button_credit_sound.play()
	credits_button_anim.play("pressed")

	
	
func _on_animated_credit_b_animation_finished() -> void:
	GlobalSignals.scene_controller.change_game_scene("res://Hud/credits_screen.tscn", false, false)
	credits_button.hide()
	$ControlCreditB/PanelCredits.hide()
	
func _on_quit_button_onstart_pressed() -> void:
	button_quit_sound.play()
	quit_button_start_anim.play()


func _on_animated_sprite_2d_animation_finished() -> void:
	get_tree().quit()
