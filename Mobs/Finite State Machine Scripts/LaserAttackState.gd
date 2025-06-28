class_name LazerAttackState extends State


@export var enemy: CharacterBody2D
@export var laser_scene: PackedScene

@onready var sprite = enemy.get_child(0)
var directions =[Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
var current_direction = directions[0]
var is_shooting : bool
var fire_duration = 2.5
var break_duration = 1.0
var directions_fired = 0
@onready var fire_timer: Timer = $FireTimer
@onready var direction_swap_timer: Timer = $DirectionSwapTimer
@onready var laser: RayCast2D = $"../../RayCast2D"



func Enter():
	sprite.animation = "channelling attack"
	enemy.velocity = Vector2()
	is_shooting = false
	directions_fired = 0
	if (randf() > 0.5):
		directions.reverse()#for both possible directions
	start_shooting_cycle()


func Exit():
	sprite.animation = "following"

func start_shooting_cycle():
	direction_swap_timer.start(break_duration)
	change_direction()
	

func change_direction():
	is_shooting = false
	sprite.animation = "channelling attack"
	if(directions_fired > 3):
		Transitioned.emit(self, "moving")
		return
	
	current_direction = directions[directions_fired]
	directions_fired +=1
	direction_swap_timer.start(break_duration)



func _on_fire_timer_timeout() -> void:
	laser.is_casting = false
	sprite.animation = "channelling attack"
	change_direction()


##break timer
func _on_direction_swap_timer_timeout() -> void:
	
	sprite.animation = "attacking"
	shooting_cycleV2(current_direction)


func shooting_cycleV2(direction: Vector2):
	laser.look_at(enemy.global_position + direction)
	laser.is_casting = true
	fire_timer.start(fire_duration)
