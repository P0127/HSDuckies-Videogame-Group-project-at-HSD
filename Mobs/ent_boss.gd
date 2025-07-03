class_name SirQuackAlot extends CharacterBody2D

##BOSS IS ON LAYERS 2 AND 5 SO THAT IT INTERACTS WITH PLAYER BULLETS AND IS NOT ALWAYS PUSHABLE

@export var attack_dmg: float = 5
@export var max_health = 100
@onready var health = max_health
@onready var progressBar: ProgressBar = $CanvasLayer/ProgressBar
@onready var label: Label = $CanvasLayer/Label
@onready var laser: RayCast2D = $RayCast2D
@onready var laser2: RayCast2D = $laser2
@onready var stablaser: RayCast2D = $stab
@onready var state_machine: Node = $"State Machine"

##Variables that multiple States use
var phase2 : bool
var last_pos 
#cant have array of all possible positions here, needs to be in using states
var dont_push_me: bool #still WIP to test out pushing
#maybe add stab attack if player is being a bully and blocking path
@onready var player = get_tree().get_first_node_in_group("Player")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/ProgressBar.max_value = max_health
	$CanvasLayer/ProgressBar.value = health
	phase2 = false
	initial_laser_setup()
	dont_push_me = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !dont_push_me:
		move_and_slide()
	else:
		self.global_position += velocity * delta
	$CanvasLayer/ProgressBar.value = health

func take_damage():
	if health > 0:
		health -= 1
		progressBar.show()
		label.show()
	if health == 0:
		#_die()
		health = -1
		progressBar.hide()
		label.hide()
	
	if !phase2:#only check this if we arent already in phase2
		if health <= max_health/2:#if health reaches halfway point
			phase2 = true


##todo add a death method incl dropping final duck

func initial_laser_setup():
	laser.is_casting = false
	laser2.is_casting = false
	stablaser.is_casting = false
	stablaser.change_preset("stab")


##self defense #could also move this into moving state maybe since there its the main issue
func _on_self_defense_stab_body_entered(body: Node2D) -> void:
	if health < 96 and body == player:
		stablaser.is_casting = true
		stablaser.look_at(player.global_position)


func _on_self_defense_stab_body_exited(body: Node2D) -> void:
	if health < 96 and body == player:
		stablaser.is_casting = false
