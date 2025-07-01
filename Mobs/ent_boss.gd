class_name SirQuackAlot extends CharacterBody2D

##todo make it so that player cant push the boss

@export var attack_dmg: float = 5
@export var max_health = 100
@onready var health = max_health
@onready var progressBar: ProgressBar = $CanvasLayer/ProgressBar
@onready var label: Label = $CanvasLayer/Label
@onready var laser: RayCast2D = $RayCast2D

##Variables that multiple States use
var phase2 : bool
var last_pos 
#cant have array of all possible positions here, needs to be in using states



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/ProgressBar.max_value = max_health
	$CanvasLayer/ProgressBar.value = health
	phase2 = true
	laser.is_casting = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	move_and_slide()
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
