extends CharacterBody2D

@export var moveSpeed: float = 400.0

@onready var sprite = $sprite

func _physics_process(_delta) -> void:
	# Get input direction
	var inputDirection = Vector2.ZERO
	inputDirection.x = Input.get_axis("move_left", "move_right")
	inputDirection.y = Input.get_axis("move_up", "move_down")
	inputDirection = inputDirection.normalized()

	# Set velocity and move player using CharacterBody2D's methods
	velocity = inputDirection * moveSpeed
	move_and_slide()

	# Handle animations based on movement
	if velocity.length() > 0:
		# Player is moving
		if sprite.animation != "walk":
			sprite.play("walk")
	else:
		# Player is stopped
		if sprite.animation != "idle":
			sprite.play("idle")

	# Flip sprite based on movement direction
	if velocity.x < 0:
		sprite.flip_h = true
	elif velocity.x > 0:
		sprite.flip_h = false
