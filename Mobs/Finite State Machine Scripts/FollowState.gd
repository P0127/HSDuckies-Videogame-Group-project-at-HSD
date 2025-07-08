class_name FollowState extends State


@export var enemy: CharacterBody2D
@export var move_speed := 100
var player: CharacterBody2D
var duck_status : int = 1 #modifier for running direction, dependant on wether it's a duck (1) or student (-1)

@onready var progress_bar = owner.find_child("ProgressBar")

func Enter():
	
	#upon entering boss aggro range the health bar appears
	progress_bar.set_deferred("visible", true)
	
	player = get_tree().get_first_node_in_group("Player")
	#enemy.AnimatedSprite2D.animation = "following" #this doesnt work
	var sprite = enemy.get_child(0) 

func Physics_Update(delta: float):
	var direction = player.global_position - enemy.global_position
	
	if direction.length() > 160:
		#if player is too far to hit follow
		enemy.velocity = direction.normalized() * move_speed
	#else:
		#if player is in range switch to attack state
		#Transitioned.emit(self, "attack")

	if direction.length() > 700:
		Transitioned.emit(self, "wandering")
