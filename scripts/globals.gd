class_name Globals
extends Node


static var current_wave = 0
static var total_enemy_count = 0
static var enemies_slain = 0
static var total_enemies_slain = 0


static func _enemy_slain():
	enemies_slain += 1
	total_enemies_slain += 1

	if enemies_slain >= total_enemy_count:
		_all_enemies_slain()


static func _all_enemies_slain():
	total_enemy_count = 0
	enemies_slain = 0
	SignalBus.wave_completed.emit()
