class_name AudioEffectCollectionResource
extends Resource
## Resource Script that stores a collection of AudioEffects.

@export var master_effects: Dictionary[String, ModifiedAudioEffect] = {}
@export var music_effects: Dictionary[String, ModifiedAudioEffect] = {}
@export var sfx_effects: Dictionary[String, ModifiedAudioEffect] = {}
