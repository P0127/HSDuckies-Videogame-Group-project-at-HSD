class_name SleepState extends State


@export var enemy: CharacterBody2D

@onready var laser: RayCast2D = $"../../RayCast2D"
@onready var laser_2: RayCast2D = $"../../laser2"
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
	Transitioned.emit(self, "teleport") #maybe wakeup spin attack into tp out

func Exit():
	spin_attack()

func spin_attack():
	laser.change_preset("small")
	laser_2.change_preset("small")
	laser.is_casting = true
	laser_2.is_casting = true
	var tween = create_tween()
	tween.tween_property(laser, "rotation_degrees", 180, 2)
	var tween2 = create_tween()
	tween2.tween_property(laser_2, "rotation_degrees", 0, 2)
	await get_tree().create_timer(2).timeout 
	
	laser.is_casting = false
	laser_2.is_casting = false
