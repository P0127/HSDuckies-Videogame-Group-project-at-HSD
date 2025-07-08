class_name SleepState extends State
## SLEEP STATE ##
##This is a simple sleep state, our enemy will not move till it has taken 5 hits of damage.
##Upon taking the first 5th hit, it will do a little spin attack using 2 lasers that each 
##turn 180° around itself, as a warning for the player.
##After the spin attack is complete it will swap to the teleport State and leave.

#the mob that uses the state machine
@export var enemy: CharacterBody2D

## Variables
@onready var laser: RayCast2D = $"../../laser1"
@onready var laser_2: RayCast2D = $"../../laser2"
@onready var progress_bar = owner.find_child("ProgressBar")
@onready var starting_health = enemy.max_health
@onready var spritePlayer = $"../../AnimatedSprite2D"
#saveslot for deciding when we wake up

#upon entering sleep state swap sprite to sleeping/passive mode
func Enter():
	var sprite = enemy.get_child(0)

#check each frame if we have taken >= 5 damage, if yes its time to wake up
func Update(delta: float):
	if starting_health - enemy.health >= 5:
		wakeUp()

#called upon reaching 95% health
func wakeUp():
	var sprite = enemy.get_child(0)
	sprite.animation = "awoken"
	#maybe play a quack sound or do a fancy zoom on it/doubt we have time for wakeup animation
	Transitioned.emit(self, "teleport") 
	#swap to teleport state after spin wake up attack

#upon leaving the sleep state the boss do a small initial spin attack
func Exit():
	spin_attack()

#function that executes the spin attack
func spin_attack():
	#set laser presets 
	laser.change_preset("small")
	laser_2.change_preset("small")
	#turn lasers on
	laser.is_casting = true
	laser_2.is_casting = true
	
	#make lasers rotate around the boss
	var tween = create_tween()
	tween.tween_property(laser, "rotation_degrees", 180, 1.75)
	var tween2 = create_tween()
	tween2.tween_property(laser_2, "rotation_degrees", 0, 1.75)
	
	#wait for the rotation to complete
	await get_tree().create_timer(2).timeout 
	
	#turn the lasers back off
	laser.is_casting = false
	laser_2.is_casting = false
