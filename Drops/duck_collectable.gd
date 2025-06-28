extends Area2D
#Handles Drop-Item "Duck" and it's collisions
#Is initiated by Item-Manager for Mobs or Trashcans
#Sends out GlobalSignal for "a duck got collected"

## LOCAL SIGNALS
signal path_finished 

## VARIABLES PATHING
var pathing_finished : bool = false #stops physics calculation
var collision_wall : bool = false #Signals path to not update x axis movement (stops at wall)
var last_position_x #Saveslot for x position prior wall collision - to enable wall slide

## SCENES
@onready var quack = $collecting_sound
@onready var duckSprite = $DuckPath/DuckPathFollow/AnimatedSprite2D
@onready var animationPlayer = $DuckPath/DuckPathFollow/AnimatedSprite2D/AnimationPlayer
@onready var pathing = $DuckPath/DuckPathFollow
@onready var path = $DuckPath

## FUNCTIONS PRESETS
#Called when the node enters the scene tree for the first time.
func _ready():
	#Starts Animation on initiation
	duckSprite.play("flapping")
	
	#Duck stops following the path and stops flapping
	path_finished.connect(_on_path_finished)

@warning_ignore("unused_parameter")
#Called every frame
func _physics_process(delta):
	#Runs aslong Duck hasn't reached "sitting" spot
	if !pathing_finished:
		pathing.progress_ratio += 0.015 #path ratio works from 0-1
		
		#collision_wall is set in Method _on_collision_body_entered (duck touches wall)
		if !collision_wall:
			last_position_x = pathing.position.x #Saves last held position to enable wall slide
		else:
			pathing.position.x = last_position_x #Sets x to last valid x-position prior collision
		
		#Area2D needs CollisionShape, can't be automaticly moved by path
		$CollisionShape2D.global_position = duckSprite.global_position
		
		if pathing.progress_ratio == 1:
			path_finished.emit() #if end of path has been reached

#Called by Signal path_finished, sets Duck sprite to sitting and stops pathing
func _on_path_finished():
	duckSprite.animation = "default"
	pathing_finished = true

@warning_ignore("unused_parameter")
#Waits for Feather Particles to dissapear before removing Instance
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()

@warning_ignore("unused_parameter")
#If Player touches CollectionShape (larger than Collision for ease)
#Plays sound, plays particles
func _on_collection_area_body_entered(body: Node2D) -> void:
	GlobalSignals.duck_collected_signal.emit()
	
	quack.set_deferred("pitch_scale", randf_range(1.1, 1.6)) #Random pitch to add variety
	quack.play()
	animationPlayer.play("collected") 

#If Wall is touched via CollisionShape
#Checks which direction has been touched, determines remaining pathing
func _on_collision_body_entered(body: Node2D) -> void:
	var collision_point = to_local(body.global_position) #Wall position, relative to local
	#Collision on right or left side
	if collision_point.x != 0: 
		collision_wall = true #Starts wall slide in _physics_process
	#Collision below
	if collision_point.y < 0: 
		path_finished.emit() #Stops pathing, duck sits
