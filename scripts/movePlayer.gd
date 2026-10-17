
extends CharacterBody3D

const SPEED = 5.0
const GRAVITY = 9.8

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	var input_dir = Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
        "ui_down"
	)

	velocity.x = input_dir.x * SPEED
	velocity.z = input_dir.y * SPEED

	move_and_slide()
