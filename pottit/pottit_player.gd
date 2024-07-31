extends CharacterBody3D

# Powers, transformere fiender. Puzzle
# 	magic staff m/powers
#	ta tak og kaste fiender
# 		powers: stun, float, ?? 
# INGEN HOPP
# Carry and throw: fiende

enum STATE {
	# idle,
	running,
	falling,
}

enum POWER {
	floating,
	other1,
	other2,
	other3,
}

enum ACTION {
	none = 0,
	# idle = 0,
	# running,
	# stop_running,
	# quick_turn,
	# jump,
	# doublejump,
	land,
}

const MAX_SPEED: float = 6.5
const ACCELERATION_SPEED: float = 500.0
const DECELERATION_SPEED_GROUND: float = 200.0
const DECELERATION_SPEED_AIR: float = 16.0

# const JUMP_VELOCITY: float = 6.5
# const DOUBLE_JUMP_VELOCITY: float = 5.5
const GRAVITY_SCALE_MAX: float = 1.7
const GRAVITY_SCALE_DELTA_INCREASE: float = 2.2
const GRAVITY_SCALE_BASE: float = 1.0
var gravity_scale: float = GRAVITY_SCALE_BASE
# const MAX_JUMPS: int = 2

class FrameAnimationUpdate:
	const LAND_MIN_VELOCITY_ROLL: float = MAX_SPEED / 2.0 # when to land standstill or with roll
	const MIN_X_VELOCITY_STOP: float = MAX_SPEED / 5.0

	var input: Vector2
	var velocity: Vector2
	var state: STATE = STATE.falling
	var action: ACTION
	var pivot_dir: int = -1 # facing right by default

	func set_frame_animation_update(update: FrameAnimationUpdate) -> void:
		input = update.input
		velocity = update.velocity
		state = update.state
		action = update.action
		if update.pivot_dir != 0:
			pivot_dir = update.pivot_dir
var prev_frame_anim_update: FrameAnimationUpdate

var state: STATE
var num_jumps: int

var start_pos: Vector3

func round_to_dec(num, digit) -> float:
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func _ready() -> void:
	state = STATE.falling
	num_jumps = 0
	prev_frame_anim_update = FrameAnimationUpdate.new()
	start_pos = position

func _physics_process(delta: float) -> void:
	var frame_anim_update = FrameAnimationUpdate.new()
	# Add the gravity.
	if not is_on_floor():
		gravity_scale = min(gravity_scale + delta * GRAVITY_SCALE_DELTA_INCREASE, GRAVITY_SCALE_MAX)
		velocity += get_gravity() * gravity_scale * delta
		state = STATE.falling

	# Input and Horizontal velocity adjustment
	var input_vec: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down", 0.05)
	frame_anim_update.input = input_vec

	if abs(input_vec.x):
		velocity.x = move_toward(velocity.x, input_vec.x * MAX_SPEED, ACCELERATION_SPEED * delta)
	else:
		if state == STATE.running:
			velocity.x = move_toward(velocity.x, 0, DECELERATION_SPEED_GROUND * delta)
		elif state == STATE.falling:
			velocity.x = move_toward(velocity.x, 0, DECELERATION_SPEED_AIR * delta)
	
	velocity.x = round_to_dec(velocity.x, 1)

	# Landing
	match state:
		STATE.falling:
			if is_on_floor():
				frame_anim_update.action = ACTION.land
				state = STATE.running
				num_jumps = 0
		STATE.running:
			gravity_scale = GRAVITY_SCALE_BASE

	# Handle jump.
	# if Input.is_action_just_pressed("jump") and num_jumps < MAX_JUMPS:
	# 	if is_on_floor():
	# 		frame_anim_update.action = ACTION.jump
	# 		num_jumps += 1
	# 		velocity.y = JUMP_VELOCITY
	# 	else:
	# 		frame_anim_update.action = ACTION.doublejump
	# 		num_jumps = 2 # set to two in case of walking of an edge
	# 		velocity.y = DOUBLE_JUMP_VELOCITY
	# 	state = STATE.falling
	# 	gravity_scale = GRAVITY_SCALE_BASE


	# Pivot facing direction
	var x: float = round_to_dec(velocity.x, 1)
	if x > 0:
		frame_anim_update.pivot_dir = -1
	elif x < 0:
		frame_anim_update.pivot_dir = 1
	elif x == 0:
		frame_anim_update.pivot_dir = 0

	frame_anim_update.velocity = Vector2(velocity.x, velocity.y)
	frame_anim_update.state = state
	move_and_slide()
	position.z = 0
	process_animation(frame_anim_update)

func process_animation(update: FrameAnimationUpdate) -> void:
	var abs_velocity_x = abs(update.velocity.x)

	# derive context based ACTIONs
	#if !abs(update.input.x) and (abs(update.velocity.x) > FrameAnimationUpdate.MIN_X_VELOCITY_STOP) and is_on_floor():
		#update.action = ACTION.stop_running


	# match STATE for blending
	match update.state:
		STATE.running:
			$pivot/AnimationTree.set("parameters/Blend-Idle-Run/blend_amount", clamp(abs_velocity_x / MAX_SPEED, 0, 1))
			$pivot/AnimationTree.set("parameters/Blend-Falling/blend_amount", 0.0)
			$pivot/AnimationTree.set("parameters/OneShot-StopRunning/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT)
		STATE.falling:
			$pivot/AnimationTree.set("parameters/Blend-Idle-Run/blend_amount", 0.1)
			$pivot/AnimationTree.set("parameters/Blend-Falling/blend_amount", 0.85)


	# match ACTION for oneshots
	match update.action:
		#ACTION.stop_running:
			#$pivot/AnimationTree.set("parameters/OneShot-StopRunning/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		#ACTION.jump:
			#$pivot/AnimationTree.set("parameters/OneShot-Jump/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			#$pivot/AnimationTree.set("parameters/OneShot-Land/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
		#ACTION.doublejump:
			#$pivot/AnimationTree.set("parameters/OneShot-DoubleJump/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			#$pivot/AnimationTree.set("parameters/OneShot-Land/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
		ACTION.land:
			$pivot/AnimationTree.set("parameters/OneShot-Jump/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
			$pivot/AnimationTree.set("parameters/OneShot-DoubleJump/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
			
			var land_roll: float = abs(update.velocity.x) > FrameAnimationUpdate.LAND_MIN_VELOCITY_ROLL
			$pivot/AnimationTree.set("parameters/Blend-Land/blend_amount", land_roll)
			$pivot/AnimationTree.set("parameters/OneShot-Land/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


	prev_frame_anim_update.set_frame_animation_update(update)
	$pivot.rotation.y = deg_to_rad(prev_frame_anim_update.pivot_dir * -90)
