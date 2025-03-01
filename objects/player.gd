extends CharacterBody2D

@export var move_speed: float = 400.0

@onready var sprite = $sprite
@onready var animation = $animation
@onready var weapon_slot = $weapon_slot
@onready var attack_cooldown = $attack_cooldown
@onready var interaction_area = $interaction_area

func _physics_process(_delta) -> void:
  # Get input direction
  var input_direction = Vector2.ZERO

  # Only allow movement if not attacking or picking up
  if !is_attacking() and !is_picking_up():
    input_direction.x = Input.get_axis('move_left', 'move_right')
    input_direction.y = Input.get_axis('move_up', 'move_down')
    input_direction = input_direction.normalized()

  # Set velocity and move player using CharacterBody2D's methods
  velocity = input_direction * move_speed
  move_and_slide()

  # Only check for inputs if not busy with animations
  if !is_attacking() and !is_picking_up():
    # Check for attack input if cooldown is over
    if Input.is_action_just_pressed('attack') and !attack_cooldown.time_left:
      attack()

    # Check for interaction input
    if Input.is_action_just_pressed('interact'):
      check_for_interaction()

  # Only update animations if not busy with attack or pickup animations
  if !is_attacking() and !is_picking_up():
    # Handle animations based on movement
    if velocity.length() > 0:
      # Player is moving
      if animation.current_animation != 'walk':
        animation.play('walk')
    else:
      # Player is stopped
      if animation.current_animation != 'idle':
        animation.play('idle')

  # Flip sprite based on movement direction
  if velocity.x < 0:
    sprite.flip_h = true
  elif velocity.x > 0:
    sprite.flip_h = false

  # Update weapon sprite flipping to match player
  if has_weapon():
    var weapon = weapon_slot.get_child(0)
    assert(weapon.has_node('sprite'), 'Weapon must have a sprite node')
    var weapon_sprite = weapon.get_node('sprite')
    weapon_sprite.flip_h = sprite.flip_h

func is_attacking() -> bool:
  return animation.current_animation == 'kick' or animation.current_animation == 'club_attack'

func is_picking_up() -> bool:
  return animation.current_animation == 'pickup'

func has_weapon() -> bool:
  if weapon_slot == null:
    return false

  return weapon_slot.get_child_count() > 0

func attack() -> void:
  attack_cooldown.start()

  if has_weapon():
    animation.play('club_attack')
  else:
    animation.play('kick')

func check_for_interaction() -> void:
  # Get all areas currently overlapping with our interaction area
  var overlapping_areas = interaction_area.get_overlapping_areas()

  # Check if any of them are from a weapon object
  for area in overlapping_areas:
    # Skip if already being picked up by anyone
    if area.has_meta('being_picked_up'):
      continue

    var parent = area.get_parent()
    if parent.is_in_group('weapon'):
      # Found a weapon to pick up
      animation.play('pickup')
      # Store reference to the player that's picking it up
      area.set_meta('being_picked_up', self)
      break

func pick_up_object() -> void:
  # Find the weapon that's being picked up (marked during interaction)
  var overlapping_areas = interaction_area.get_overlapping_areas()

  for area in overlapping_areas:
    if area.has_meta('being_picked_up') and area.get_meta('being_picked_up') == self:
      var weapon = area.get_parent()

      # Clear any existing weapons in the slot
      for child in weapon_slot.get_children():
        child.queue_free()

      # Instantiate the in-hand version of the weapon
      assert(weapon.in_hand_version != null, 'Weapon must have an in-hand version')
      var weapon_in_hand = weapon.in_hand_version.instantiate()

      # Add it to the weapon slot
      weapon_slot.add_child(weapon_in_hand)

      # Remove the original weapon from the scene
      weapon.queue_free()

      # Sync the weapon sprite flipping and frame to the player
      var weapon_sprite = weapon_in_hand.get_node('sprite')
      assert(weapon_sprite != null, 'Weapon sprite must exist')
      weapon_sprite.flip_h = sprite.flip_h
      weapon_sprite.frame = sprite.frame

      break

func _on_animation_animation_started(anim_name):
  # Check if player has a weapon
  if has_weapon():
    # Get the first weapon in the weapon slot
    var weapon = weapon_slot.get_child(0)

    # Ensure weapon has an animation node
    assert(weapon.has_node('animation'), 'Weapon must have an animation node')
    var weapon_anim = weapon.get_node('animation')

    # Ensure weapon has the same animation as the player
    assert(weapon_anim.has_animation(anim_name), 'Weapon must have animation: ' + anim_name)
    weapon_anim.play(anim_name)
