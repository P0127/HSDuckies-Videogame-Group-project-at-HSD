@tool
extends RayCast2D

## Variables
@export var cast_speed := 7000.0#The higher the cast speed the faster the beam extends
@export var max_length := 1400.0
@export var start_distance := 40.0#distance from the caster
@export var growth_time := 0.1
@export var damage_rate := 5.0

#player reference for collision and damge
@onready var player = get_tree().get_first_node_in_group("Player")

## Status 
#set here makes it so that the following method counts as its setter method
@export var is_casting := false: set = set_is_casting
@export var color := Color.WHITE: set = set_color

## Variables for laser effect
@onready var outerLine: Line2D = $outerLine #line_2d
@onready var outerWidth := outerLine.width #line_2d.width
@onready var innerLine: Line2D = $innerLine #line_2d2
@onready var innerWidth := innerLine.width #line_2d2.width

## Constants for presets
const DEFAULT_INNER_WIDTH := 10.0
const DEFAULT_OUTER_WIDTH := 20.0
const UPPED_INNER_WIDTH := 15.0
const UPPED_OUTER_WIDTH := 30.0
const LOWERED_INNER_WIDTH := 5.0
const LOWERED_OUTER_WIDTH := 10.0

var tween: Tween = null
var tween2: Tween = null

#Called when the node enters the scene tree for the first time
func _ready() -> void:
	set_color(color)
	set_is_casting(is_casting)
	outerLine.points[0] = Vector2.RIGHT * start_distance
	outerLine.points[1] = Vector2.ZERO
	outerLine.visible = false
	innerLine.points[0] = Vector2.RIGHT * start_distance
	innerLine.points[1] = Vector2.ZERO
	innerLine.visible = false

#function called every frame to calculate the raycast and if enabled deal damage
func _physics_process(delta: float) -> void:
	target_position.x = move_toward( #calculate ending position
		target_position.x, #direction
		max_length,        #length
		cast_speed * delta #speed
	)
	
	var laser_end_position := target_position
	force_raycast_update()
	
	if is_colliding(): #if we are colliding then get the position of the collision
		laser_end_position = to_local(get_collision_point())
		if get_collider() == player:
			#if collider is player deal damage
			player.take_damage(delta, damage_rate)
		elif get_collider() is CharacterBody2D and get_collider().has_method("take_damage"):
			#if collider is a mob
			get_collider().take_damage()
	
	if outerLine == null or innerLine == null:
		return
	
	#set ending positions to collision positions
	outerLine.points[1] = laser_end_position
	innerLine.points[1] = laser_end_position


#setter method for is_casting that enables/disables the laser including its visibility
func set_is_casting(new_value: bool):
	#if old value=new value do nothing
	if is_casting == new_value:
		return
	
	is_casting = new_value
	set_physics_process(is_casting)
	
	if not outerLine or not innerLine:
		return
	
	if is_casting: #adjust laser positions and appear or disappear
		var laser_start := Vector2.RIGHT * start_distance
		outerLine.points[0] = laser_start
		outerLine.points[1] = laser_start
		innerLine.points[0] = laser_start 
		innerLine.points[1] = laser_start 
		appear()
	else:
		target_position = Vector2.ZERO
		disappear()

#setter function for the outer color
func set_color(new_color: Color):
	color = new_color
	if outerLine == null:
		return
	outerLine.modulate = new_color

#function to make the laser appear using tweens for a small animation
func appear():
	#enable visibility
	outerLine.visible = true
	innerLine.visible = true
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(outerLine, "width", outerWidth, growth_time * 2.0).from(0.0)
	#make laser grow over 2x growth time
	
	if tween2 and tween2.is_running():
		tween2.kill()
	tween2 = create_tween()
	tween2.tween_property(innerLine, "width", innerWidth, growth_time * 2.0).from(0.0)
	#make laser grow over 2x growth time

func disappear():
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(outerLine, "width", 0.0, growth_time).from_current()
	tween.tween_callback(outerLine.hide)
	#make laser shrink and disappear over 1x growth time
	#disappearing is twice as fast as appearing
	
	if tween2 and tween2.is_running():
		tween2.kill()
	tween2 = create_tween()
	tween2.tween_property(innerLine, "width", 0.0, growth_time).from_current()
	tween2.tween_callback(innerLine.hide)
	#make laser shrink and disappear over 1x growth time
	#disappearing is twice as fast as appearing


#function to change laser stats to different predefined presets
#use preset depending on what kind of attack the boss goes for
func change_preset(preset: String):
	match (preset):
		"small":
			outerWidth = LOWERED_OUTER_WIDTH
			innerWidth = LOWERED_INNER_WIDTH
			max_length = 200
			growth_time = 1
			cast_speed = 3000
			
		"big":
			outerWidth = UPPED_OUTER_WIDTH
			innerWidth = UPPED_INNER_WIDTH
			start_distance = 80
		"stab":
			outerWidth = LOWERED_OUTER_WIDTH
			innerWidth = LOWERED_INNER_WIDTH
			start_distance = 20
			max_length = 80
		"phase2":
			innerLine.default_color = Color.BLACK
			outerLine.modulate = Color.WHITE
		_:#unknown input sets laser to default preset
			outerWidth = DEFAULT_OUTER_WIDTH
			innerWidth = DEFAULT_INNER_WIDTH
			start_distance = 40
			max_length = 1400
			growth_time = 0.1
			if outerLine.width_curve:
				outerLine.width_curve = null
			if innerLine.width_curve:
				innerLine.width_curve = null
