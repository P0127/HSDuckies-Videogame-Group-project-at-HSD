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
	
	# sprite.animation = "walk_side"
	## SPRITE ORIENTATION
	_rotate_sprite()

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


#function that manages the sprite animation
func _rotate_sprite():
	var sprite = enemy.get_child(0)
	if enemy.velocity != Vector2.ZERO:
		#int to eliminate decimals (reduces errors)
		#rad to deg to have easy, whole numbers to work with
		#velocity.angle() gives back angle (right is 1,0 - down is 0,1) in radians!
		var angle_formatted = rad_to_deg((enemy.velocity.angle()))
		
		if angle_formatted >= -120 and angle_formatted <= -60:
			sprite.animation = "walk_back"
		elif angle_formatted >= 20 and angle_formatted <= 160:
			sprite.animation = "walk_front"
		else:
			sprite.animation = "walk_side"
		#Flips Animation if walking to the side
		sprite.flip_h = enemy.velocity.x < 0 * duck_status
	else:
		sprite.animation = "walk_front"
