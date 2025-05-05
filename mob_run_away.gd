extends CharacterBody2D #this scene is for the mob running away from the player after having been defeated

var movement_speed = 300#more speed than mob so that they run away fast
@onready var main = $"/root/Main"
@onready var player = $"/root/Main/Player"
var target #saveslot for current target to make it possible to run out of aggro range

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	velocity = Vector2.ZERO
	if target:
		velocity = global_position.direction_to(target.global_position) * movement_speed * -1#*-1 to get opposite direction
		move_and_slide()
	
	#are we moving upwards? if yes enable backview of model
	if (velocity.y > 0):#this will prob change later as it is a little scuffed
		$AnimatedSprite2D.animation = "back_view"
	else:
		$AnimatedSprite2D.animation = "front_view"
	
	#are we running left or right? 
	if (velocity.x < 0):
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false


#if player is in range set target to player to know who to run away from
func _on_vision_circle_body_entered(body):
	if (body == player):
		target = player



#if we leave screen despawn
func _on_visible_on_screen_enabler_2d_screen_exited():
	queue_free()


func _on_time_to_live_timeout():
	queue_free()
