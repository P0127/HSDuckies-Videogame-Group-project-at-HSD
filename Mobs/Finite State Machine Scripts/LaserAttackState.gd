class_name LaserAttackState extends State


@export var enemy: CharacterBody2D

@onready var sprite = enemy.get_child(0)
var directions = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
var current_direction = directions[0]
var fire_duration = 2.5
var break_duration = 1.0
var directions_fired = 0
@onready var fire_timer: Timer = $FireTimer
@onready var direction_swap_timer: Timer = $DirectionSwapTimer
@onready var laser: RayCast2D = $"../../RayCast2D"



func Enter():
	sprite.animation = "channelling attack"
	#enemy.velocity = Vector2()#dont think this line is needed but maybe if we slide later upon entry
	directions_fired = 0
	
	##this needs to be called in Enter else the first laser from first state entry is invisible
	laser.is_casting = false
	
	#directions.shuffle() #for rdm direction order
	if (randf() > 0.5):
		directions.reverse()#for both possible spin directions
	start_shooting_cycle()


func Exit():
	sprite.animation = "following"

func start_shooting_cycle():
	direction_swap_timer.start(break_duration)
	change_direction()

func change_direction():
	sprite.animation = "channelling attack"
	if(directions_fired > 3):
		var swapTo = randf()
		if(swapTo > 0.99):
			Transitioned.emit(self, "moving")
			return
		else:
			Transitioned.emit(self, "teleport")
			return
	
	current_direction = directions[directions_fired]
	directions_fired +=1
	direction_swap_timer.start(break_duration)

##fire duration timer
func _on_fire_timer_timeout() -> void:
	laser.is_casting = false
	sprite.animation = "channelling attack"
	change_direction()


##break timer
func _on_direction_swap_timer_timeout() -> void:
	sprite.animation = "attacking"
	shooting_cyclePart2(current_direction)


func shooting_cyclePart2(direction: Vector2):
	laser.look_at(enemy.global_position + direction)
	laser.is_casting = true
	#could add a distance collision check here that if laser collides with a wall within 200px
	#we turn laser off, change sprite, reopen change_direction() and return so that timer doesnt start
	#if collision check
		#try with next direction
		#return
	fire_timer.start(fire_duration)
