extends CharacterBody2D

@export var speed = 200 #player movement speed in pixels/sec
var screen_size #game window size

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	hide() #hides player on startup to avoid showing behind hud


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		#normalized so that player is not faster moving diagonally 
	
	#check for collisions
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		pass #could add sth if player walks into wall prob not needed unless we want to add a spiky wall or so?
	else:
		position += velocity * delta #if no collision player is allowed to move
	position = position.clamp(Vector2.ZERO, screen_size)#clamp makes sure player cant leave screen

#function for start of game to move player to start position and show player
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
