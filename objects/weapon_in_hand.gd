extends Node2D

@export_file('*.tscn') var on_ground_version: String
@export var attackAnimation: String

# Has to be defined because it is called in the player's animation
func drop_weapon() -> void:
  pass
