class_name Monster
extends CharacterEntity

var monster_type

@onready var player = get_tree().get_first_node_in_group("player")

var is_player_in_range = false
var is_attacking = false
var attack_cooldown = 0


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if player:
		var direction = global_position.direction_to(player.global_position)

		if is_attacking == true:
			velocity.x = 0
		elif invulnerability_frames > 0:
			velocity.x = direction.x * -50
		else:
			velocity.x = direction.x * max_speed

		if velocity.x > 0:
			$Sprite.flip_h = true
			$AttackHitboxes.scale.x = -1.0
		elif velocity.x < 0:
			$Sprite.flip_h = false
			$AttackHitboxes.scale.x = 1.0

	move_and_slide()


func _process(delta: float) -> void:
	invulnerability_frames -= 1
	attack_cooldown -= delta
	if is_player_in_range and attack_cooldown <= 0:
		_attack()
	


func _attack():
	is_attacking = true
	attack_cooldown = 1

	# need to add a wind up thing
	
	$Sprite.play("attack_windup")
	print("winding up")
	await get_tree().create_timer(0.6).timeout
	print("swingin")
	$Sprite.play("attacking")
	$AttackHitboxes/AttackHitbox/Attack.disabled = false
	
	await get_tree().create_timer(1.15).timeout
	
	$AttackHitboxes/AttackHitbox/Attack.disabled = true
	is_attacking = false
	$Sprite.play("default")


func _take_damage(damage_amount: int):
	current_health_points -= damage_amount
	
	if current_health_points <= 0:
		queue_free()
		Globals._enemy_slain()
	
	invulnerability_frames = 20


func _heal(heal_amount: int):
	
	current_health_points += heal_amount
	
	if current_health_points > max_health_points:
		current_health_points = max_health_points


static func _create(_max_hp: int, _atk_dmg: int, _atk_spd: float, _armor: int, _max_speed: float, _accl: float, _atk_size: int, _monster_type: String) -> Monster:
	var monster: Monster = preload("res://objects/monster.tscn").instantiate()
	
	monster.max_health_points = _max_hp
	monster.current_health_points = monster.max_health_points
	monster.attack_damage = _atk_dmg
	monster.attack_speed = _atk_spd
	monster.armor = _armor
	monster.max_speed = _max_speed
	monster.acceleration = _accl
	monster.attack_size = _atk_size
	monster.monster_type = _monster_type
	monster.invulnerability_frames = 0
	return monster


func _player_in_range(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_in_range = true


func _player_exited_range(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_in_range = false


func _player_hit_us(area: Area2D) -> void:
	print("getting hit")
	if area.is_in_group("player") and invulnerability_frames <= 0:
		_take_damage(player.attack_damage)
