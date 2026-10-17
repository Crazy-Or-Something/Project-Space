extends CharacterBody3D

# CRITICAL DEPENDENCY
# DO NOT DELETE THIS FILE.

const LIL_TUB: Texture2D = preload("res://assets/core/lil tub.png")

const SPEED: float = 5.0
const RUN_SPEED: float = 8.0
const JUMP_SPEED: float = 4.5
const SENSITIVITY: float = 0.003
const ACCELERATION: float = 12.0
const FRICTION: float = 30.0
const BRAKING: float = 35.0
const AIR_ACCELERATION: float = 2.0
const TILT_SIDE: float = 2.5
const TILT_FORWARD: float = 1.5
const TILT_SMOOTHING: float = 8.0

const BOB_FREQUENCY: float = 2.0
const BOB_AMPLITUDE: float = 0.035
const BOB_SMOOTHING: float = 12.0

var bob_time: float = 0.0

@onready var head: Node3D = $HeadPivot
@onready var tilt: Node3D = $HeadPivot/TiltPivot
@onready var pcam_plr: PhantomCamera3D = $HeadPivot/TiltPivot/PCamPlr
@onready var head_origin: Vector3 = head.position


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pcam_plr.set_priority(10)


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
			head.rotate_x(-event.relative.y * SENSITIVITY)

			head.rotation.x = clampf(
				head.rotation.x,
				deg_to_rad(-89),
				deg_to_rad(89)
			)


func _apply_head_bob(delta: float) -> void:
	var horizontal_speed: float = Vector2(
		velocity.x,
		velocity.z
	).length()

	var target_position: Vector3 = head_origin

	if is_on_floor() and horizontal_speed > 0.1:
		bob_time += delta * horizontal_speed * BOB_FREQUENCY

		target_position.y += sin(bob_time) * BOB_AMPLITUDE
		target_position.x += cos(bob_time * 0.5) * BOB_AMPLITUDE * 0.5

	head.position = head.position.lerp(
		target_position,
		minf(BOB_SMOOTHING * delta, 1.0)
	)

func _apply_camera_tilt(_delta: float) -> void:
	var local_velocity: Vector3 = (
		global_transform.basis.inverse() *
		Vector3(velocity.x, 0.0, velocity.z)
	)
	
	var _side: float = 0.0
	var _forward: float = 0.0
	
	if is_on_floor():
		_side = clampf(local_velocity.x / SPEED, -1.0, 1.0)
		_forward = clampf(local_velocity.z / SPEED, -1.0, 1.0)
	
	

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

	var current_speed: float = SPEED

	if Input.is_action_pressed("player_run"):
		current_speed = RUN_SPEED

	var target_velocity = direction * current_speed
	var rate: float

	if is_on_floor():
		if direction == Vector3.ZERO:
			rate = FRICTION
		elif horizontal_velocity.dot(direction) < 0.0:
			rate = BRAKING
		else:
			rate = ACCELERATION
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
	_apply_head_bob(delta)
