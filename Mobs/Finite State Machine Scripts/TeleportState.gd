class_name TeleportState extends State


@export var enemy: CharacterBody2D
@onready var sprite = enemy.get_child(0)

##setup so that we can lazer fire into all hallways
##prob work with set points on the map play animation tp there


##Array of all main Boss Positions
@onready var allPossiblePositions = [
	$"../../../Test_Tilemap/BossPos1",
	$"../../../Test_Tilemap/BossPos2",
	$"../../../Test_Tilemap/BossPos3",
	$"../../../Test_Tilemap/BossPos4"
]
var next_pos
var waitBefore : float = 2.0
var waitAfter : float = 1.0
var enemyTeleported : bool

func Enter():
	##select random point where we will path to
	var indexPos = randi_range(0,3)
	next_pos = allPossiblePositions[indexPos]
	##play animation
	#animation_player.play("teleport")
	#await animation_player.animation_finished
	waitBefore = 2.0
	sprite.animation = "passive"
	enemyTeleported = false

func Update(delta: float):
	if waitBefore > 0:
		waitBefore -= delta
	else:
		var tween = create_tween()
		tween.tween_property(sprite, "self_modulate:a", 0.0, 1.0)
		#Fade out to 0% opacity over 1 second
		
		teleport()
		waitBefore = 500 #not fancy but to bugtest so that we dont reopen teleport() on repeat
		

##insert key in animation to link to teleport method
func teleport():
	#wait for fadeout to fully play
	await get_tree().create_timer(1).timeout
	
	#teleport enemy
	enemy.global_position = next_pos.global_position
	
	#play fadein
	var tween = create_tween()
	tween.tween_property(sprite, "self_modulate:a", 1.0, 1.0)
	#Fade out to 100% opacity over 1 second
	
	#wait for fadein to fully play
	await get_tree().create_timer(1).timeout
	Transitioned.emit(self, "laserattack")



func Exit():
	print("teleport state exit called")


func _on_opacity_timer_timeout() -> void:
	teleport()
	
	var tween = create_tween()
	tween.tween_property(sprite, "self_modulate:a", 1.0, 1.0)
	#Fade out to 100% opacity over 1 second
	#else:
		#var tween = create_tween()
		#tween.tween_property(sprite, "self_modulate", 0.1, 1.0)
		##Fade in to 10% opacity over 1 second
		#opacity_timer.start(1.0)
