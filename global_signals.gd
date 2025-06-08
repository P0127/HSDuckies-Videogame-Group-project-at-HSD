extends Node#this script is for now only meant for GLOBAL SIGNALS
#basically add in a signal here that you want to carry between two nodes but cant with normal signal
#do GlobalSignals.signalname.emit() instead of just signalname.emit()
#and then you have to connect it in the _ready function to whatever function you want to
#activate whenever the signal is emitted through GlobalSignals.signalname.connect(funcname)
#yes only funcname in the brackets no funcname() or funcname(parameter)

signal duck_collected_signal
signal reduce_mob_counter
signal mob_level_up

var timerSpeedUp = Timer.new()
var timerFirerate = Timer.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(timerSpeedUp)
	add_child(timerFirerate)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
