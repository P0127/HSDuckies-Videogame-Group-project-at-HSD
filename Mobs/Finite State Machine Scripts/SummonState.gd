class_name SummonState extends State


@export var enemy: CharacterBody2D
#var summon = load("res://Mobs/mob.tscn").instantiate()

#ideas: if not attacked for 10hp within 2.5sec it goes through
#if it takes x dmg within y time it swaps state to tp away
##maybe set summon chargeup to 2.5 on enter ++save current health into enter health
##count up each frame ++ check if enter health and current health are too far apart
##check if positions left below and right are valid spawns
##spawn summons THAT DONT DROP DUCKS maybe with a static var in mobs that decides if they drop or not
##mob method to change them dropping +prob tied into map swap if 2nd floor only unlock after collecting pre final duck

#need a reference to the tilemaplayer from which we wanna check if spawnable
@onready var navLayer = $"../../../Test_Tilemap/MobSpawnableTiles"
#variable to save entry health in so that summon is interuptable
var entry_health
#value for how much dmg is required to cancel the summon
@export var damage_required = 10
#maybe help variable to cancel
var cancel: bool

##Spawnpoints NEEEDS to be a child of enemy, else it doesnt track positions correctly
@onready var individual_spawn_positions = [
	$"../../Spawnpoints/Left",
	$"../../Spawnpoints/Center",
	$"../../Spawnpoints/Right"
]
@onready var spawnpoints: Node2D = $"../../Spawnpoints"
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")

func Enter():
	#stand still
	enemy.velocity = Vector2()
	#save health from time of entering the state
	entry_health = enemy.health
	
	cancel = false
	realign_positions()
	summonMobs()

func Update(delta: float):
	if entry_health - enemy.health >= damage_required:
		cancel = true
		print("cancel set!")
		Transitioned.emit(self, "teleport")

func realign_positions():
	var lowest_distance = 999999999
	var direction
	var best_rotation
	#check North,East,South,West
	for i in range(0, 360, 90):
		spawnpoints.rotation = i
		direction = player.global_position - individual_spawn_positions[1].global_position
		if direction.length() < lowest_distance:
			lowest_distance = direction.length()
			best_rotation = i
			print("updated best direction")
	
	spawnpoints.rotation = best_rotation
	print("rotation set!")

func summonMobs():
	await get_tree().create_timer(5).timeout
	if cancel:
		print("cancel tracked and summon cancelled!")
		return
	
	var meelee1 = load("res://Mobs/mob.tscn").instantiate()
	var meelee2 = load("res://Mobs/mob.tscn").instantiate()
	var ranged = load("res://Mobs/ranged_mob.tscn").instantiate()
	
	if(navLayer.spawncheck(individual_spawn_positions[0].global_position)):
		var tween = create_tween()
		#meelee1.self_modulate.a = 0#doesnt do shit
		tween.tween_property(meelee1.spriteMob, "self_modulate:a", 0.0, 1.5)#also doesnt do shit
		meelee1.global_position = individual_spawn_positions[0].global_position
		enemy.add_sibling(meelee1)
	
	if(navLayer.spawncheck(individual_spawn_positions[1].global_position)):
		var tween = create_tween()
		tween.tween_property(ranged, "self_modulate:a", 0, 0)
		tween.tween_property(ranged, "self_modulate:a", 1.0, 1.5)
		ranged.global_position = individual_spawn_positions[1].global_position
		enemy.add_sibling(ranged)
	
	if(navLayer.spawncheck(individual_spawn_positions[2].global_position)):
		print("spawncheck worked!")
		var tween = create_tween()
		tween.tween_property(meelee2.spriteMob, "self_modulate:a", 0, 0)
		tween.tween_property(meelee2.spriteMob, "self_modulate:a", 1.0, 1.5)
		meelee2.global_position = individual_spawn_positions[2].global_position
		enemy.add_sibling(meelee2)

##BUG IF WE ADD MOBS LIKE THIS WE WILL HAVE TO DISABLE SPAWNING ENTIRELY OR ELSE IT WILL
##LOWER THE MAX MOBS TO BELOW 0 SO THAT IT ALLOWS MOBS TO SPAWN
