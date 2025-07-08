extends Node
#Knows all Drop Scenes, differentiates between ducks and consumables
#Reacts to Signals emitted on pickup or Mob death, whenever smth has to be dropped
#Initiates fitting Scene, circumvents the scenes requiring the drops to know the scene themself

var dropChance : float #Gets randomized every Function call, is "the dice being cast"

#Knows all dropable items
var ducks := preload("res://Drops/duck_collectable.tscn")
var chocobar := preload("res://Drops/drop_chocolatebar.tscn")
var energydrink := preload("res://Drops/drop_energydrink.tscn")
var mensafood := preload("res://Drops/drop_chocolatebar.tscn")

#Drop variants for consumables, can be added onto in this array
var drops = [chocobar, energydrink, mensafood]

func _ready():
	#Gets emitted in scenes where drops are needed 
	#Global_position is transmitted on Signal emit
	GlobalSignals.drop_duck.connect(_drop_duck)
	GlobalSignals.drop_item.connect(_drop_item)
	GlobalSignals.bossMinion_item.connect(_drop_bossMinion_item)

#Standard drop function to reduce code; scene is given as parameter
func _drop(spawn_global_position : Vector2, drop_scene : PackedScene):
	var drop = drop_scene.instantiate()
	drop.global_position = spawn_global_position
	
	#spawns into the current running scene, set via global scene controller
	#will run after physics proccessees, lessens errors (deferred)
	GlobalSignals.scene_controller.current_scene.call_deferred("add_child", drop)

#Function called to drop a Duck with a chance of 80%, or force it to drop always
func _drop_duck(mob_global_position : Vector2, force_drop : bool = false):
	#Has only a chance to drop a duck
	randomize()
	dropChance = randf() #Float between 0.0 and 1.0, respective to out chances
	
	if force_drop or dropChance <= 0.8: #either forced drop or 80% chance of duck drop
		_drop(mob_global_position, ducks)

#Function called to drop an item with chance (item type gets randomized)
func _drop_item(spawn_global_position : Vector2):
	#Only has a chance to drop an item
	#Has a small chance to drop a duck
	randomize()
	dropChance = randf() #Float between 0.0 and 1.0, respective to out chances
	
	#60% Chance do drop item, 1% Chance to drop Duck, 39% nothing
	if dropChance <= 0.6:
		_drop(spawn_global_position, drops[randi() % drops.size()])
	elif dropChance <= 0.61:
		_drop(spawn_global_position, ducks)
	else:
		pass 


#Function called to drop an item with chance (item type gets randomized) on Boss Minion Death
func _drop_bossMinion_item(spawn_global_position : Vector2):
	#Only has a small chance to drop an item, NO DUCKS
	randomize()
	dropChance = randf() #Float between 0.0 and 1.0, respective to out chances
	
	#33% Chance do drop item
	if dropChance <= 0.33:
		_drop(spawn_global_position, drops[randi() % drops.size()])
	else:
		pass 
