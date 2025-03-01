extends CharacterBody2D

@export var moveSpeed: float = 400.0

@onready var sprite = $sprite
@onready var attackCooldown = $attackCooldown

func _physics_process(_delta) -> void:
    # Get input direction
    var inputDirection = Vector2.ZERO

    # Only allow movement if not attacking
    if sprite.animation != 'attack':
        inputDirection.x = Input.get_axis('move_left', 'move_right')
        inputDirection.y = Input.get_axis('move_up', 'move_down')
        inputDirection = inputDirection.normalized()

    # Set velocity and move player using CharacterBody2D's methods
    velocity = inputDirection * moveSpeed
    move_and_slide()

    # Check for attack input - only if not already attacking and cooldown is over
    if Input.is_action_just_pressed('attack') and sprite.animation != 'attack' and !attackCooldown.time_left:
        attack()

    # Handle animations based on movement
    if sprite.animation != 'attack':
        if velocity.length() > 0:
            # Player is moving
            if sprite.animation != 'walk':
                sprite.play('walk')
        else:
            # Player is stopped
            if sprite.animation != 'idle':
                sprite.play('idle')

    # Flip sprite based on movement direction
    if velocity.x < 0:
        sprite.flip_h = true
    elif velocity.x > 0:
        sprite.flip_h = false

func attack() -> void:
    sprite.play('attack')
    attackCooldown.start()


func _on_sprite_animation_finished():
    if sprite.animation == 'attack':
        sprite.play('idle')
