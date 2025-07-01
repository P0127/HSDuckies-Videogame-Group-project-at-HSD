class_name SleepState extends State


@export var enemy: CharacterBody2D

@onready var progress_bar = owner.find_child("ProgressBar")
@onready var starting_health = enemy.max_health

func Enter():
	var sprite = enemy.get_child(0)
	sprite.animation = "passive"

func Update(delta: float):
	if starting_health - enemy.health >= 5:
		wakeUp()

func wakeUp():
	#maybe play a quack sound or do a fancy zoom on it/doubt we have time for wakeup animation
	Transitioned.emit(self, "moving") #maybe wakeup spin attack into tp out

func Exit():
	#GlobalSignals.toggle_mob_drops.emit()
	#GlobalSignals.toggle_natural_spawns.emit()
	#moved those two signals to the elevator
	pass
