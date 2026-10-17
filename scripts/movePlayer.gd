
extends CharacterBody3D

const SPEED: float = 5.0
const JUMP_SPEED: float = 4.5
const SENSITIVITY: float = 0.003
const ACCELERATION: float = 12.0
const FRICTION: float = 30.0
const AIR_ACCELERATION: float = 2.0

@onready var camera: Camera3D = $Camera3D


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("game_mouseLockToggle"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return

	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			rotate_y(-event.relative.x * SENSITIVITY)
			camera.rotate_x(-event.relative.y * SENSITIVITY)

			camera.rotation.x = clamp(
				camera.rotation.x,
				deg_to_rad(-89),
				deg_to_rad(89)
			)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = JUMP_SPEED
	
	var input_dir = Input.get_vector(
		"player_moveLeft",
		"player_moveRight",
		"player_moveUp",
        "player_moveDown"
	)

	var direction = (
		global_transform.basis *
		Vector3(input_dir.x, 0, input_dir.y)
	).normalized()

	var horizontal_velocity = Vector3(
		velocity.x,
		0,
		velocity.z
	)
	
	var target_velocity = direction * SPEED
	var rate: float
	
	if is_on_floor():
		if direction != Vector3.ZERO:
			rate = ACCELERATION
		else:
			rate = FRICTION
	else:
		if direction != Vector3.ZERO:
			rate = AIR_ACCELERATION
		else:
			rate = 0.0
	
	horizontal_velocity = horizontal_velocity.move_toward(
		target_velocity,
		rate * delta
	)
	
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
	
	move_and_slide()
