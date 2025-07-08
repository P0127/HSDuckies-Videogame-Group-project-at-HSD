class_name MeeleeAttackState extends State
##this was a 3hit attack attempt that didnt quite work due to there being no timer in follow that 
##denies us from going straight back to attack -> could also solve it by swapping between attack 
##patterns but dont think theres enough time + wouldnt fit as we dont have a meelee hit animation

@export var enemy: CharacterBody2D
#onready for sprite here due to multiple uses
@onready var sprite = enemy.get_child(0)
@onready var player = get_tree().get_first_node_in_group("Player")

var channel_time : float = 2 #windup time
var time_between_hits : float = 1
var hitCounter = 0

func Enter():
	enemy.velocity = Vector2()
	

func Update(delta: float):
	if channel_time > 0: 
		channel_time -= delta
	
	else:
		var direction = player.global_position - enemy.global_position
		if time_between_hits <= 0:
			time_between_hits = 1
		
		#if player out of attack range swap to follow state
		if(direction.length() > 300): 
			Transitioned.emit(self, "follow")
		
		if(time_between_hits > 0):
			time_between_hits -= delta
		else:
			player.take_damage(delta, enemy.attack_dmg)
			hitCounter += 1
			
			if(hitCounter >= 3):
				Transitioned.emit(self, "moving")
