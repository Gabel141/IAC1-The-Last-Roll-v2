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
	_end_wave()
	_show_upgrades()


static func _end_wave():
	total_enemy_count = 0
	enemies_slain = 0
	SignalBus.wave_completed.emit()


static func _show_upgrades():
	var upgrade_menu = Ui.get_node("UpgradeSelection")
	upgrade_menu.show()
	upgrade_menu.add_item("Yo", null, true)
