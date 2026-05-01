class_name GeneralUtility
extends Node
## Utility Script for generally helpful functions.

#region Functions

## Looks through a node's upward hiearchy for the closest node belonging to the specified class.[br]
## Parameters:[br]
## child: The node whose parents/ancestors are of the specific class we're searching for.[br]
## target_class: The class to search for.[br]
static func get_nearest_parent_of_class(child: Node, target_class: Variant) -> Variant:
	var result = null
	var current = child
	while result == null:
		var parent = current.get_parent()
		if parent == null:
			return null
		elif is_instance_of(parent, target_class): # If the parent is of the target class,
			return parent
		else:
			current = parent
	return null

#endregion
