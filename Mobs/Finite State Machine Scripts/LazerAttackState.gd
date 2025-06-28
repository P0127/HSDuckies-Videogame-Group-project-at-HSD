class_name LazerAttackState extends State


@export var enemy: CharacterBody2D
#onready for sprite here due to multiple uses
@onready var sprite = enemy.get_child(0)
@onready var player = get_tree().get_first_node_in_group("Player")

var channel_time : float = 2 #windup time
var time_between_hits : float = 1
var hitCounter = 0

func Enter():
	sprite.animation = "channelling attack"
	enemy.velocity = Vector2()
	

func Update(delta: float):
	if channel_time > 0: 
		channel_time -= delta
	else:
		

func Exit():
	sprite.animation = "following"
