extends Node#this script is for now only meant for GLOBAL SIGNALS
#basically add in a signal here that you want to carry between two nodes but cant with normal signal
#do GlobalSignals.signalname.emit() instead of just signalname.emit()
#and then you have to connect it in the _ready function to whatever function you want to
#activate whenever the signal is emitted through GlobalSignals.signalname.connect(funcname)
#yes only funcname in the brackets no funcname() or funcname(parameter)

## SIGNALS
@warning_ignore_start("unused_signal")
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
@warning_ignore_restore("unused_signal")

## VARIABLES
#Timers for the global effects (to avoid stacking effects) 
#get prolonged when new drop is collected before effect of prior one runs out
var timerSpeedUp = Timer.new()
var timerFirerate = Timer.new()

#Global access to Scene_Controller and it's scene change functions!!
var scene_controller : Scene_Controller
#Global access to Duck Counter (how many have been collected), as it has to be scene independent
var duck_counter : Level_Manager

## FUNCTIONS
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(timerSpeedUp)
	add_child(timerFirerate)
