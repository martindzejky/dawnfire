extends CharacterBody2D

@export var move_speed: float = 400.0

@onready var sprite = $sprite
@onready var animation = $animation
@onready var attack_cooldown = $attack_cooldown

func _physics_process(_delta) -> void:
  # Get input direction
  var input_direction = Vector2.ZERO

  # Only allow movement if not attacking
  if !is_attacking():
    input_direction.x = Input.get_axis('move_left', 'move_right')
    input_direction.y = Input.get_axis('move_up', 'move_down')
    input_direction = input_direction.normalized()

  # Set velocity and move player using CharacterBody2D's methods
  velocity = input_direction * move_speed
  move_and_slide()

  # Only check for inputs if not busy with animations
  if !is_attacking():
    # Check for attack input if cooldown is over
    if Input.is_action_just_pressed('attack') and !attack_cooldown.time_left:
      attack()

  # Only update animations if not busy with attack animations
  if !is_attacking():
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

func is_attacking() -> bool:
  # Check if current animation is kick
  return animation.current_animation == 'kick'

func attack() -> void:
  attack_cooldown.start()
  animation.play('kick')
