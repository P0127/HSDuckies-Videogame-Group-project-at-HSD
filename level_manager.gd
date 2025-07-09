class_name Level_Manager extends Node2D
#Manages the LevelUp restrictions and sends out Signals, if requirements are met
#Listens to Duck Collected Signals and manages the duck reset on game win/over


## VARIABLES
var ducks_collected : int = 0 #How many ducks the Player CURRENTLY has collected
var ducks_required_levelUp : int = 5 #How many needed for Player level up
var ducks_required_gameWon : int = 2 #How many needed for Game won


## FUNCTIONS 
func _ready():
	GlobalSignals.duck_counter = self
	GlobalSignals.duck_collected_signal.connect(duck_collected_counter)
	GlobalSignals.game_over.connect(_game_over)
	GlobalSignals.boss_slain.connect(duck_reset) #resets ducks for next game


## FUNCTIONS DUCK COUNT
#Crements global collected ducks, optional: multiple ducks are added at once
func duck_collected_counter(amount: int = 1):
	ducks_collected += amount
	
	#Checks if enough ducks were collected for victory
	if ducks_collected == ducks_required_gameWon:
		GlobalSignals.dialogue_start.emit("res://CutScene/Dialogue/ZwischenDialog_3.json")
		GlobalSignals.game_won.emit()
	#Starts Dialogue on half way to victory
	if ducks_collected == ducks_required_gameWon / 2:
		GlobalSignals.dialogue_start.emit("res://CutScene/Dialogue/ZwischenDialog_2.json")
	#Checks if LevelUp Milestone has been reached, emits Signal
	if ducks_collected % ducks_required_levelUp == 0:
		GlobalSignals.duck_collected_levelUp.emit()

#Resets duck Counter to 0
func duck_reset():
	ducks_collected = 0

## FUNCTIONS GAME STATE
#Switches HUD to game_over display 
func _game_over():
	#resets ducks collected for new game attempt
	duck_reset()
	#Calls on end screen as overlay over main and pauses/hides ingame overlay
	#hiding/pausing avoids reload on button pressed "start game anew"
	GlobalSignals.scene_controller.change_gui_scene("res://Hud/game_over.tscn", false, false)
