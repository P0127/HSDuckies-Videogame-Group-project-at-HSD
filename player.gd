extends CharacterBody2D

@export var speed = 200 #player movement speed in pixels/sec
var screen_size #game window size

# Called when the node enters the scene tree for the first time.
func _ready():
	#screen_size = get_viewport_rect().size
	#^not needed rn since we move camera with player
	#could be useful later for enemy spawning maybe if reset on every frame limit spawn area to around player?
	hide() #hides player on startup to avoid showing behind hud


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	# The player's movement vector.
	var velocity = Vector2.ZERO 
	#check for collisions
	var collision_info = move_and_collide(velocity * delta)
	
	#not needed, as collision is handled by Godot
	#Useful maybe if we want events triggered via collision
	#if collision_info:
		#if Input.is_action_pressed("move_right"):
			#velocity.x += 0
		#if Input.is_action_pressed("move_left"):
			#velocity.x += 0
		#if Input.is_action_pressed("move_down"):
			#velocity.y += 0
		#if Input.is_action_pressed("move_up"):
			#velocity.y += 0
	#else: position += velocity * delta
		
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
	
	#Which Animation plays, should be added on to 
	#Flips Animation if walking to the side
	if velocity.x != 0:
		$AnimatedPlayerSprite.animation = "walk"
		# uprightposture
		$AnimatedPlayerSprite.flip_v = false
		$AnimatedPlayerSprite.flip_h = velocity.x > 0
	
	#Player can move
	position += velocity * delta

#function for start of game to move player to start position and show player
func start(pos):
	position = pos
	show()
	#starts the animation
	$AnimatedPlayerSprite.play()
	$PlayerCollisionShape.disabled = false
