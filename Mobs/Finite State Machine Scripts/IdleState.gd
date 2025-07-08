class_name IdleState extends State

@export var enemy: CharacterBody2D #this is what we are aka what is using this state and NOT WHAT IS THE ENEMY OF WHO IS USING THIS STATE
@export var move_speed := 50.0

var player : CharacterBody2D

var move_direction : Vector2
var wander_time : float

func randomize_wandering():
	move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	wander_time = randf_range(1, 4)

func Enter():
	player = get_tree().get_first_node_in_group("Player")
	var sprite = enemy.get_child(0)
	sprite.animation = "sleep"
	randomize_wandering()

func Update(delta: float):
	if wander_time > 0: #could add a check for current speed != 0 so that if we walk into a wall we swap direction
		wander_time -= delta
	
	else:
		randomize_wandering()

func Physics_Update(delta: float):
	if enemy:
		enemy.velocity = move_direction * move_speed
	
	var direction = player.global_position - enemy.global_position
	if direction.length() < 500:
		Transitioned.emit(self, "follow")
