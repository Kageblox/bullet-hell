class_name SceneInstance
extends Node
## Instance Script that oversees and represents a single Scene.

#region Signals

## Emitted when the scene has been instantiated, but is obscured by the loading screen.
signal on_entry_start()

## Emitted when the scene has been instantiated, and is no longer obscured by the loading screen.
signal on_entry_end()

## Emitted when the scene is about to be deleted, but is still visible.
signal on_exit_start()

## Emitted right before the scene is deleted.
signal on_exit_end()

#endregion

#region Variables

@export var pausable: bool = false

@export var focus_control: Control

#endregion

#region Functions

## Called when the scene has been instantiated, but is obscured by the loading screen.
func entry_start() -> void:
	pass

## Called when the scene has been instantiated, and is no longer obscured by the loading screen.
func entry_end() -> void:
	pass

## Called when the scene is about to be deleted, but is still visible.
func exit_start() -> void:
	pass

## Called right before the scene is deleted.
func exit_end() -> void:
	pass

#endregion
