class_name SaveLoadUtility
extends Node
## Utility Script for Saving and Loading various types of Files.

const SETTINGS_DEFAULT_PC: SettingsDataResource = preload("res://resource(tres)/data/settings/settings_default_pc.tres") as SettingsDataResource
const SETTINGS_DEFAULT_WEB: SettingsDataResource = preload("res://resource(tres)/data/settings/settings_default_web.tres") as SettingsDataResource

#region Resource

## Saves a resource to the specified location.
## Parameters:[br]
## resource: The resource to save.[br]
## location: The file path to save the resource to.[br]
static func save_resource(resource: Resource, location: String) -> void:
	var path = "user://" + location + ".tres"
	var error = ResourceSaver.save(resource, path)
	if error != OK:
		push_error("Error saving resource: ", error)
	else:
		print("Resource saved successfully to: ", path)


## Returns the resource stored at the specified location.
## Parameters:[br]
## location: The location where the resource is saved at.[br]
## type_hint: The resource's class name.[br]
static func load_resource(location: String, type_hint: String = "") -> Resource:
	var path = "user://" + location + ".tres"
	if FileAccess.file_exists(path):
		var loaded_resource = ResourceLoader.load(path, type_hint, ResourceLoader.CACHE_MODE_IGNORE)
		if loaded_resource:
			print("Resource loaded successfully: ", location)
			return loaded_resource
		else:
			push_error("Error loading resource: ", location)
	push_error("Resource does not exist: ", location)
	return null


## Deletes the resource stored at the specified location.
## Parameters:[br]
## location: The location where the resource is saved at.[br]
static func delete_resource(location: String) -> void:
	_delete_file(location, ".tres")
	
#endregion

#region Image

## Saves an image to the specified location.
## Parameters:[br]
## image: The image to save.[br]
## location: The file path to save the image to.[br]
static func save_image(image: Image, location: String) -> void:
	image.save_png("user://" + location + ".png")


## Returns the image stored at the specified location.
## Parameters:[br]
## location: The location where the image is saved at.[br]
static func load_image(location: String) -> Image:
	return Image.load_from_file("user://" + location + ".png")


## Deletes the image stored at the specified location.
## Parameters:[br]
## location: The location where the image is saved at.[br]
static func delete_image(location: String) -> void:
	_delete_file(location, ".png")

#endregion

#region Settings

## Saves the provided settings.
## Parameters:[br]
## new_settings: The settings resource to save.[br]
static func save_settings(new_settings: SettingsDataResource) -> void:
	save_resource(new_settings, "settings")


## Retrieves the saved settings, and provides the default ones if there's none.
static func load_settings() -> SettingsDataResource:
	var loaded_settings = load_resource("settings", "SettingsDataResource") as SettingsDataResource
	if loaded_settings == null:
		return SETTINGS_DEFAULT_PC
	else:
		return loaded_settings

## Deletes saved settings.
static func delete_settings() -> void:
	delete_resource("settings")

#endregion

#region Internal

## Deletes the file stored at the specified location.
## Parameters:[br]
## location: The location where the file is saved at.[br]
## file_type: The type of file to delete.[br]
static func _delete_file(location: String, file_type: String) -> void:
	var path = "user://" + location + file_type
	if FileAccess.file_exists(path):
		var error = DirAccess.remove_absolute(path)
		if error == OK:
			print("Deleted Resource:" + location)
		else:
			push_error("Error deleting Resource: ", location, " Error code: ", str(error))
	else:
		print("Resource not found: ", location)

#endregion
