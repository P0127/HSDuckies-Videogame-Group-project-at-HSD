extends Node
#Handles global Signals, Nodes and Effects
#Autorun on Gamestart
#Please check connections in Doc

## SIGNALS
@warning_ignore_start("unused_signal")
#Change in Game State
signal game_over
signal game_won

#Tracking Duck Counter
signal duck_collected_signal
signal duck_collected_levelUp

#For spawning Items
signal drop_duck
signal drop_item

#Mob Level and spawn limitation
signal reduce_mob_counter

#Dialogues that pause the game
signal dialogue_finished
signal dialogue_start

#Scene independent Sound
signal play_sound(name)
signal stop_sound(name)
@warning_ignore_restore("unused_signal")

## GLOBAL NODES
#Global access to Scene_Controller and it's scene change functions!!
var scene_controller : Scene_Controller
#Global access to Duck Counter (how many have been collected), as it has to be scene independent
var duck_counter : Level_Manager

## GLOBAL EFFECTS
#Timers for global effects (to avoid stacking effects) 
#get prolonged when new drop is collected before effect of prior one runs out
var timerSpeedUp = Timer.new()
var timerFirerate = Timer.new()

#Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(timerSpeedUp)
	add_child(timerFirerate)
