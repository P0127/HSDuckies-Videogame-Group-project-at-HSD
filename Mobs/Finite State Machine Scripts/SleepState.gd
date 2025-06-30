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
