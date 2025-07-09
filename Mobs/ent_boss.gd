class_name SirQuackAlot extends CharacterBody2D
			  ## Important ##
##This Boss uses a state Machine, meaning most of the functionalities are happening
## inside the individual States. Each State has a short summary at the top + additional
## step by step descriptions throughout the code.

## Variables #Damage is defined in laser and laser.change_preset()
@export var max_health = 100
@onready var health = max_health

# Nodes we need to adjust
@onready var progressBar: ProgressBar = $CanvasLayer/ProgressBar
@onready var label: Label = $CanvasLayer/Label
@onready var laser: RayCast2D = $laser1
@onready var laser2: RayCast2D = $laser2
@onready var stablaser: RayCast2D = $stab
@onready var entbossSprite = $AnimatedSprite2D

@onready var stateLasering = $"State Machine/LaserAttack"
@onready var stateSleeping = $"State Machine/Sleep"
@onready var stateTeleporting = $"State Machine/Teleport"

##Variables that multiple States use
var phase2 : bool
var last_pos 
#cant have array of all possible positions here, needs to be in using states

#player reference for self defense stab- Area2D
@onready var player = get_tree().get_first_node_in_group("Player")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#inital healthbar setup
	$CanvasLayer/ProgressBar.max_value = max_health
	$CanvasLayer/ProgressBar.value = health
	
	entbossSprite.animation = "sleep"
	
	phase2 = false
	initial_laser_setup()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	
	#Depending on Velocity angle and state, changes Sprite
	if health > 0: #this fixes nullpointerexception after getting rid of state machine child
		
		#boss DOESNT move with move_and_slide() to deny player pushing it too much
		self.global_position += velocity * delta
		
		match ($"State Machine".current_state):
			stateSleeping:
				if health < 100:
					entbossSprite.play("wake_up")
			stateTeleporting:
				pass
			stateLasering:
				entbossSprite.play("channelling attack")
			_:
				_rotate_sprite()
	
	#update health
	$CanvasLayer/ProgressBar.value = health

#basic function of how the boss takes damage
func take_damage():
	if health > 0:
		health -= 1
		progressBar.show()
		label.show()
	if health == 0:
		_die()
		health = -1
		progressBar.hide()
		label.hide()
	
	if !phase2:#only check this if we arent already in phase2
		if health <= max_health/2:#if health reaches halfway point
			phase2 = true
			GlobalSignals.phase2_reached.emit()

#basic death function will trigger animation
func _die(): #might move this to a death state
	$AnimatedSprite2D/AnimationPlayer.play("death")
	initial_laser_setup() #turns off all lasers
	self.find_child("State Machine").queue_free() #stops state machine
	
	#Fires Signal to enable PC pool cutscene trigger
	GlobalSignals.boss_slain.emit()


#function that manages the sprite animation
func _rotate_sprite():
	if velocity != Vector2.ZERO:
		#int to eliminate decimals (reduces errors)
		#rad to deg to have easy, whole numbers to work with
		#velocity.angle() gives back angle (right is 1,0 - down is 0,1) in radians!
		var angle_formatted = rad_to_deg((velocity.angle()))
		
		if angle_formatted >= -120 and angle_formatted <= -60:
			entbossSprite.play("walk_back")
		elif angle_formatted >= 20 and angle_formatted <= 160:
			entbossSprite.play("walk_front")
		else:
			entbossSprite.play("walk_side")
		#Flips Animation if walking to the side
		entbossSprite.flip_h = velocity.x < 0
	else:
		entbossSprite.animation = "stand"

#Calls on the preloaded duck drop scene to instantiate it once
func drop_item():
	GlobalSignals.drop_duck.emit(global_position)

#inital setup for all lasers attached to the boss
func initial_laser_setup():
	laser.is_casting = false     #have to set is_casting for lasers individually like this
	laser2.is_casting = false    #setting it in the _ready of BossLaser results in
	stablaser.is_casting = false #invisible lasers
	stablaser.change_preset("stab")


#if a player tries to bodyblock the boss or push it, a small laser will fire in his direction
#laser is set to weaker as its not meant to kill just show player to not block the boss
func _on_self_defense_stab_body_entered(body: Node2D) -> void:
	if health < 96 and body == player and health > 0:
		stablaser.is_casting = true
		stablaser.look_at(player.global_position)

#upon leaving close proximity of the boss the stab laser gets turned off
func _on_self_defense_stab_body_exited(body: Node2D) -> void:
	if health < 96 and body == player:
		stablaser.is_casting = false

#When death animation has finnished
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pass
