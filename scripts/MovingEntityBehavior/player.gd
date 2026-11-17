extends CharacterEntity

# BASE MOVEMENT VARIABLES
var jump_velocity

# DASH VARIABLES
var dash_velocity
var is_dashing
var dash_timer
var dash_duration
var dash_max_charges
var dash_current_charges
var dash_current_cooldown
var dash_cooldown

# BASIC ATTACK VARIABLES

var attack_cooldown = 1
var attack_cooling_value = 0
var is_attacking = false
var attack_duration = 0

func _ready() -> void:
	max_health_points = 100
	current_health_points = 100
	attack_damage = 10
	attack_speed = 1.0
	armor = 0
	speed = 300.0
	invulnerability_frames = 0

	# BASE MOVEMENT VARIABLES
	jump_velocity = -600.0

	# DASH VARIABLES
	dash_velocity = 600
	is_dashing = false
	dash_timer = 0.0
	dash_duration = 0.2
	dash_max_charges = 2
	dash_current_charges = 2
	dash_current_cooldown = 0.0
	dash_cooldown = 1

	attack_cooldown = 1
	attack_cooling_value = 0
	is_attacking = false
	attack_duration = 0


func _physics_process(delta: float) -> void: # need to move some stuff away from here, like attacks and shit
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	var mouse_pos = get_global_mouse_position()

	# DASH AND MOVEMENT
	
	# checks for dash input
	if is_dashing and direction != 0:
		velocity.x = direction * dash_velocity

	if is_dashing: # handles dash cooldown and status
		dash_current_cooldown = dash_cooldown
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			velocity.x = move_toward(velocity.x, 0, 200) # slows down
	else: # part of the is_dashing if, needs to move somewhere else as it handles movement
		if direction:
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)

	if dash_current_charges < dash_max_charges:
		dash_current_cooldown -= delta # better to move this to a _process function
		if dash_current_cooldown <= 0 and dash_current_charges < dash_max_charges:
			dash_current_charges += 1
			dash_current_cooldown = dash_cooldown
	
	move_and_slide()
	
	# sprite direction handling WILL PROBABLY MOVE THIS LATER
	
	if mouse_pos.x > global_position.x:
		$AnimatedSprite2D.flip_h = true
		$AttackHitboxes.scale.x = -1
	else:
		$AnimatedSprite2D.flip_h = false
		$AttackHitboxes.scale.x = 1

	# attacks
	
func _process(delta: float) -> void:
	invulnerability_frames -= 1
	attack_cooling_value -= delta
	if attack_duration > 0:
		attack_duration -= delta
	if attack_duration <= 0:
		is_attacking = false
		$AttackHitboxes/Basic_Attack/CollisionShape2D.disabled = true
		$AttackHitboxes/Basic_Attack/BasicAttackAnim.play("default")
		$AnimatedSprite2D.play('default')
	
	if Input.is_action_pressed("attack") and not is_attacking and attack_cooling_value <= 0:
		_attack()
	
	if $"/root/Ui":
		var UI: CanvasLayer = $"/root/Ui"
		
		UI.get_node("Health").text = "Health: " + str(current_health_points) + " / " + str(max_health_points)
		UI.get_node("Dashes").text = "Dashes: " + str(dash_current_charges) + " / " + str(dash_max_charges)


func _attack():
	is_attacking = true
	attack_duration = 0.35
	attack_cooling_value = attack_cooldown
	if is_attacking:
		$AnimatedSprite2D.play("basic_attack")
		$AttackHitboxes/Basic_Attack/CollisionShape2D.disabled = false
		$AttackHitboxes/Basic_Attack/BasicAttackAnim.play("attacking")

func _input(event: InputEvent) -> void:

	# dash input
	if event.is_action_pressed("dash") and not is_dashing and dash_current_charges > 0 and velocity.x != 0:
		print("DASHED")
		dash_current_charges -= 1
		is_dashing = true
		dash_timer = dash_duration

	# special attack input
func _take_damage(damage_amount: int):
	print("ow")
	current_health_points -= damage_amount
	invulnerability_frames = 15
	SignalBus.player_hit.emit()
	
	if current_health_points <= 0:
		SignalBus.player_died.emit()
		queue_free()

func _heal(heal_amount: int):
	
	current_health_points += heal_amount
	
	if current_health_points > max_health_points:
		current_health_points = max_health_points

func _player_was_hit(area: Area2D):
	if area.is_in_group("enemies") and invulnerability_frames <= 0:
		var attacking_enemy = area.get_parent().get_parent()
		print("Player took " + str(attacking_enemy.attack_damage) +  " damage!")
		_take_damage(attacking_enemy.attack_damage)
