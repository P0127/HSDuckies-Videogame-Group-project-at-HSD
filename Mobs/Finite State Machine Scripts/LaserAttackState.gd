class_name LaserAttackState extends State
## Laser Attack State ##
##This State will fire a laser in all 4 cardinal directions once in a random order.
##How long each laser is fired is decided by the fire_duration variable, whilst the
## delay, between the laser getting disabled in one direction and enabled into another
## direction, is set through the break_duration variable.
##After having fired in all 4 directions it will transition to a movement State.


## Variables
@export var enemy: CharacterBody2D
@onready var sprite = enemy.get_child(0)
var directions = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
var current_direction = directions[0]
@export var fire_duration = 2.5
@export var break_duration = 1.0
var directions_fired = 0
@onready var fire_timer: Timer = $FireTimer
@onready var direction_swap_timer: Timer = $DirectionSwapTimer
@onready var laser: RayCast2D = $"../../laser1"
@onready var laser_2: RayCast2D = $"../../laser2"
@onready var stablaser: RayCast2D = $"../../stab"


func _ready():
	if not GlobalSignals.phase2_reached.is_connected(phase2Started):
		GlobalSignals.phase2_reached.connect(phase2Started)

func Enter():
	#swap sprite
	sprite.animation = "channelling attack"
	
	#set shots fired counter to 0
	directions_fired = 0
	
	#set both main lasers to the default preset
	laser.change_preset("default")
	laser_2.change_preset("default")
	#2nd laser is currently not used in laser attack but might be in the future
	#especially for phase 2 would make sense
	
	directions.shuffle() #for rdm direction order
	
	start_shooting_cycle()
	
	enemy.velocity = Vector2.ZERO

func start_shooting_cycle():
	direction_swap_timer.start(break_duration)
	change_direction()


#function that updates our currently selected direction
func change_direction():
	if(directions_fired > 3): #if we've fired in all directions
		swapState()# swap state
		return
	
	#update current direction
	current_direction = directions[directions_fired]
	directions_fired +=1
	direction_swap_timer.start(break_duration)

##fire duration timer
func _on_fire_timer_timeout() -> void:
	laser.is_casting = false #turn laser off
	#initiate shooting just with a different direction
	change_direction()


##break timer
func _on_direction_swap_timer_timeout() -> void:
	shooting_cyclePart2(current_direction)

# called in break timer timeout
func shooting_cyclePart2(direction: Vector2):
	#make laser look at our current direction
	laser.look_at(enemy.global_position + direction)
	laser.is_casting = true#turn laser on
	
	#could add a distance collision check here that if laser collides with a wall within 200px
	#we turn laser off, change sprite, reopen change_direction() and return so that timer doesnt start
	#if collision check
		#try with next direction
		#return
	
	fire_timer.start(fire_duration)
	#start fire timer which will turn the laser off again

func swapState():
	if enemy.phase2:
		var swapTo = randf()
		if(swapTo > 0.5): #50%chance for moving state
			Transitioned.emit(self, "moving")
		else: #50% chance for teleport state
			Transitioned.emit(self, "teleport")
	else:#if we arent in phase2 always swap to moving state
		Transitioned.emit(self, "moving")


#function thats called upon reaching phase 2 which will be called only once
#this will change the laser colors and adjust stats
func phase2Started():
	#change colors from red-white to white-black
	laser.change_preset("phase2")
	laser_2.change_preset("phase2")
	stablaser.change_preset("phase2")
	
	fire_duration = 1.5
	break_duration = 0.5
