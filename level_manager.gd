class_name Level_Manager extends Node2D

## VARIABLES
var ducks_collected : int = 0 #How many ducks the Player CURRENTLY has collected
var ducks_required_levelUp : int = 10 #How many needed for Player level up
var ducks_required_gameWon : int = 35 #How many needed for Game won

## FUNCTIONS 
func _ready():
	GlobalSignals.duck_counter = self
	GlobalSignals.duck_collected_signal.connect(duck_collected_counter)
	
	GlobalSignals.game_over.connect(_game_over)


## FUNCTIONS DUCK COUNT
#Crements global collected ducks, optional: multiple ducks are added at once
func duck_collected_counter(amount: int = 1):
	ducks_collected += amount
	
	if ducks_collected == ducks_required_gameWon:
		GlobalSignals.dialogue_start.emit("res://Dialogue_cutscenes/ZwischenDialog_3.json")
		GlobalSignals.game_won.emit()
	
	if ducks_collected == ducks_required_gameWon / 2:
		GlobalSignals.dialogue_start.emit("res://Dialogue_cutscenes/ZwischenDialog_2.json")
	
	if ducks_collected % ducks_required_levelUp == 0:
		duck_collected_levelUp()

func duck_collected_levelUp():
	GlobalSignals.duck_collected_levelUp.emit()

func duck_gameOver():
	ducks_collected = 0


## FUNCTIONS GAME STATE
func _game_over():
	#resets ducks collected for new game attempt
	GlobalSignals.duck_counter.duck_gameOver()
	#Calls on end screen as overlay over main and pauses/hides ingame overlay
	#hiding/pausing avoids reload on button pressed "start game anew"
	GlobalSignals.scene_controller.change_gui_scene("res://Hud/game_over.tscn", false, false)
	
func _game_won():
	GlobalSignals.scene_controller.change_game_scene("res://CutScene/Dialogue/Dialogue_Ende.tscn")
	GlobalSignals.scene_controller.remove_gui()
