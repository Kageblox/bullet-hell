class_name SceneManagerGlobal
extends Node
## Global Script in charge of Scenes.[br]
## Also handles the loading screen.

#region Signals

signal on_scene_entry_start(_scene: SceneInstance)
signal on_scene_entry_end(_scene: SceneInstance)
signal on_scene_exit_start(_scene: SceneInstance)
signal on_scene_exit_end(_scene: SceneInstance)

#endregion

#region Variables

const PAUSE_BUTTON_RESOURCE: Resource = preload("res://scene(tscn)/ui/pause_button.tscn")
const LOADING_SCREEN_RESOURCE: Resource = preload("res://scene(tscn)/ui/menus/loading_screen.tscn")

## The currently active Scene Instance.
var current_scene: SceneInstance

var _loading_screen : MenuInstance
var _pause_button: TextureButton

## The currently loading scene's path. Null if no scenes are currently loading.
var _loading_path = null

#endregion

#region Functions

func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	## Instantiates and adds the pause button under this node.
	_pause_button = PAUSE_BUTTON_RESOURCE.instantiate()
	add_child(_pause_button)
	_pause_button.visible = false
	_pause_button.pressed.connect(
		func():
			MenuManager.open_pause_menu()
			)
	
	## Instantiates and adds the loading screen under this node.
	_loading_screen = LOADING_SCREEN_RESOURCE.instantiate()
	add_child(_loading_screen)
	_loading_screen.visible = false

	

func _ready() -> void:
	for child in get_tree().root.get_children():
		if child is SceneInstance:
			current_scene = child
			break

	if current_scene:
		get_tree().current_scene = current_scene
		
		current_scene.entry_start()
		current_scene.on_entry_start.emit()
		_pause_button.visible = current_scene.pausable

	else:
		push_error("No SceneInstance in current scene.")
		

func _process(_delta: float) -> void:
	if _loading_path != null:
		var loading_status = ResourceLoader.load_threaded_get_status(_loading_path)
		match loading_status:
			# Once the next scene has been loaded,
			ResourceLoader.THREAD_LOAD_LOADED:
				
				# Close the loading screen.
				_loading_screen.close()
				
				# In case some menus have yet to close, delete them instantly.
				MenuManager.close_all_menus(true)
				
				# Retrieve the fully loaded next scene.
				var loaded_scene_resource = ResourceLoader.load_threaded_get(_loading_path) as Resource
				_loading_path = null
				
				# Delete the previous scene.
				current_scene.queue_free()
				
				# Replaces the deleted scene with the new one.
				current_scene = loaded_scene_resource.instantiate() as SceneInstance

				get_tree().root.add_child(current_scene)
				get_tree().current_scene = current_scene
				
				on_scene_entry_start.emit(current_scene)

				current_scene.entry_start()
				current_scene.on_entry_start.emit()
				_pause_button.visible = current_scene.pausable
				
				await get_tree().create_timer(_loading_screen.close_duration).timeout
				
				on_scene_entry_end.emit(current_scene)
				
				current_scene.entry_end()
				current_scene.on_entry_end.emit()
				
			ResourceLoader.THREAD_LOAD_FAILED:
				push_error("Failed to load: " + _loading_path)

			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				push_error(_loading_path + " is invalid")


## Initiates the transition to another scene.[br]
## Parameters:[br]
## _path: The resource path of the scene to transition to.
func goto_scene(_path: String) -> void:
	
	on_scene_exit_start.emit(current_scene)
	
	current_scene.exit_start()
	current_scene.on_exit_start.emit()
	
	# Opens the loading screen.
	_loading_screen.open()
	
	# Closes all menus.
	MenuManager.close_all_menus(false)
	
	# Wait for the loading screen to fully obscure the screen.
	await get_tree().create_timer(_loading_screen.open_duration).timeout
	
	on_scene_exit_end.emit(current_scene)
	
	current_scene.exit_end()
	current_scene.on_exit_end.emit()
	
	# Initiate the loading process.
	_loading_path = _path
	ResourceLoader.load_threaded_request(_loading_path)
	
#endregion
