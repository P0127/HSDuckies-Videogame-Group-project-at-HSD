@tool
extends RayCast2D

##The higher the cast speed the faster the beam extends
@export var cast_speed := 7000.0
@export var max_length := 1400.0
@export var start_distance := 40.0
@export var growth_time := 0.1
@export var damage_rate := 5.0


#for collision and damge
@onready var player = get_tree().get_first_node_in_group("Player")


##set here makes it so that the following method counts as its setter method
@export var is_casting := false: set = set_is_casting
@export var color := Color.WHITE: set = set_color

##variables for laser effect
@onready var line_2d: Line2D = $outerLine
@onready var line_width := line_2d.width
@onready var line_2d2: Line2D = $innerLine
@onready var line_width2 := line_2d2.width
const DEFAULT_INNER_WIDTH := 10.0
const DEFAULT_OUTER_WIDTH := 20.0
const UPPED_INNER_WIDTH := 15.0
const UPPED_OUTER_WIDTH := 30.0
const LOWERED_INNER_WIDTH := 5.0
const LOWERED_OUTER_WIDTH := 10.0

var tween: Tween = null
var tween2: Tween = null


func _ready() -> void:
	set_color(color)
	set_is_casting(is_casting)
	line_2d.points[0] = Vector2.RIGHT * start_distance
	line_2d.points[1] = Vector2.ZERO
	line_2d.visible = false
	line_2d2.points[0] = Vector2.RIGHT * start_distance
	line_2d2.points[1] = Vector2.ZERO
	line_2d2.visible = false


func _physics_process(delta: float) -> void:
	target_position.x = move_toward(
		target_position.x, #direction
		max_length,        #length
		cast_speed * delta #speed
	)
	
	var laser_end_position := target_position
	force_raycast_update()
	if is_colliding():
		laser_end_position = to_local(get_collision_point())
		if get_collider() == player:
			#if collider is player deal damage
			player.take_damage(delta, damage_rate)
		elif get_collider() is CharacterBody2D and get_collider().has_method("take_damage"):
			#if collider is a mob
			get_collider().take_damage()
	
	if line_2d == null or line_2d2 == null:
		return
	
	line_2d.points[1] = laser_end_position
	line_2d2.points[1] = laser_end_position



func set_is_casting(new_value: bool):
	if is_casting == new_value:
		return
	is_casting = new_value
	set_physics_process(is_casting)
	
	if not line_2d or not line_2d2:
		return
	
	if is_casting:
		var laser_start := Vector2.RIGHT * start_distance
		line_2d.points[0] = laser_start
		line_2d.points[1] = laser_start
		line_2d2.points[0] = laser_start 
		line_2d2.points[1] = laser_start 
		appear()
	else:
		target_position = Vector2.ZERO
		disappear()

func set_color(new_color: Color):
	color = new_color
	if line_2d == null:
		return
	line_2d.modulate = new_color


func appear():
	line_2d.visible = true
	line_2d2.visible = true
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(line_2d, "width", line_width, growth_time * 2.0).from(0.0)
	
	if tween2 and tween2.is_running():
		tween2.kill()
	tween2 = create_tween()
	tween2.tween_property(line_2d2, "width", line_width2, growth_time * 2.0).from(0.0)

func disappear():
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(line_2d, "width", 0.0, growth_time).from_current()
	tween.tween_callback(line_2d.hide)
	
	if tween2 and tween2.is_running():
		tween2.kill()
	tween2 = create_tween()
	tween2.tween_property(line_2d2, "width", 0.0, growth_time).from_current()
	tween2.tween_callback(line_2d2.hide)

#testing function for different laser width for different states
#this can work for maybe spin attack upon waking up
#have presets that change width and length to make it match whatever attack we want
func adjust_width(preset: int):
	match (preset):
		-1:
			line_width = LOWERED_OUTER_WIDTH
			line_width2 = LOWERED_INNER_WIDTH
		1:
			line_width = UPPED_OUTER_WIDTH
			line_width2 = UPPED_INNER_WIDTH
		_:
			line_width = DEFAULT_OUTER_WIDTH
			line_width2 = DEFAULT_INNER_WIDTH
