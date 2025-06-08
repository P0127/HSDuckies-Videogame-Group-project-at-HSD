extends Node

var dropChance : float

#Knows all dropable items
var ducks := preload("res://Drops/duck_collectable.tscn")
var chocobar := preload("res://Drops/drop_chocolatebar.tscn")
var energydrink := preload("res://Drops/drop_energydrink.tscn")
var mensafood := preload("res://Drops/drop_chocolatebar.tscn")

#DropVariants
var drops = [chocobar, energydrink, mensafood]

@onready var main = $"/root/Main"

func _ready():
	#Gets emitted in scenes where drops are needed 
	#Get global_position argument given with
	GlobalSignals.drop_duck.connect(_drop_duck)
	GlobalSignals.drop_item.connect(_drop_item)

#Standard drop function to reduce code; scene is given as parameter
func _drop(spawn_global_position : Vector2, drop_scene : PackedScene):
	var drop = drop_scene.instantiate()
	drop.global_position = spawn_global_position
	#will run after physics proccessees, lessens errors (deferred)
	main.call_deferred("add_child", drop)

func _drop_duck(mob_global_position : Vector2):
	_drop(mob_global_position, ducks)

func _drop_item(spawn_global_position : Vector2):
	#Only has a chance to drop an item
	#Has a small chance to drop a duck
	randomize()
	dropChance = randf() #Float between 0.0 and 1.0, respective to out chances
	
	#60% Chance do drop item, 1% Chance to drop Duck, 39% nothing
	if dropChance <= 0.6:
		_drop(spawn_global_position, drops[randi() % drops.size()])
	elif dropChance <= 0.65:
		_drop(spawn_global_position, ducks)
	else:
		pass 
