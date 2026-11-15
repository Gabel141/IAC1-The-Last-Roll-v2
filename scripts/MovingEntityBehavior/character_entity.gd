@abstract 
class_name CharacterEntity 
extends CharacterBody2D

# need to make this an abstract class

var max_health_points
var current_health_points
var attack_damage
var attack_speed
var armor
var speed
var attack_size

var invulnerability_frames

var max_speed
var acceleration

@abstract func _attack()

func _take_damage(damage_amount: int):
	current_health_points -= damage_amount

func _heal(heal_amount: int):
	
	current_health_points += heal_amount
	
	if current_health_points > max_health_points:
		current_health_points = max_health_points
