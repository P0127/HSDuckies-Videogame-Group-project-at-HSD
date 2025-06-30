class_name Scene_Controller extends Node

#Controls Scenes, loads/unloads

## VARIABLES
#Our control nodes in our scene_controller Nodes for both HUD and game scenes
@export var world2D : Node2D
@export var gui : Control


#Currently playing/needed scenes
var current_scene
var current_gui


## FUNCTIONS
func _ready():
	#Sets global variable to this class, functions can be called globally
	GlobalSignals.scene_controller = self
	
	#This is what we start with; our start screen!
	GlobalSignals.scene_controller.change_gui_scene("res://Hud/startscreen.tscn")

func change_game_scene (new_scene_name: String, delete: bool = true, visibility: bool = false):
	remove_scene(delete, visibility)
	#loads new scene and starts it
	var new_scene = load(new_scene_name).instantiate()
	current_scene = new_scene
	print("Current Scene: ", current_scene)
	world2D.add_child(new_scene)

func change_gui_scene (new_gui_name: String, delete: bool = true, visibility: bool = false):
	remove_gui(delete, visibility)
	#loads new scene and starts it
	var new_gui = load(new_gui_name).instantiate()
	current_gui = new_gui
	print("Current GUI: ", current_gui)
	gui.add_child(new_gui)

func remove_scene (delete: bool = true, visibility: bool = false):	
	#Only if there is a scene already loaded, does it manipulate the prior scene
	if current_scene != null:
		if delete:
			#removes scene entirely
			current_scene.queue_free() 
		elif visibility:
			#keeps running, just not showing
			current_scene.visibile = false
		else:
			#keeps in memory, but doesn't update session (no reload necessary on recall)
			world2D.remove_child(current_scene)

func remove_gui (delete: bool = true, visibility: bool = false):
	#Only if there is a scene already loaded, does it manipulate the prior scene
	if current_gui != null:
		if delete:
			#removes scene entirely
			current_gui.queue_free() 
		elif visibility:
			#keeps running, just not showing 
			current_gui.visible = false
		else:
			#keeps in memory, but doesn't update session (no reload necessary on recall)
			gui.remove_child(current_gui)
