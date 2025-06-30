class_name SirQuackAlot extends CharacterBody2D

##todo make it so that player cant push the boss

@export var attack_dmg: float = 5
var health = 100
@onready var progressBar: ProgressBar = $CanvasLayer/ProgressBar
@onready var label: Label = $CanvasLayer/Label

##variables that some states check
var phase2 : bool
var last_pos 



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/ProgressBar.max_value = health
	$CanvasLayer/ProgressBar.value = health
	phase2 = false


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


##todo add a death method incl dropping final duck
