extends Node2D

@onready var spawn_locations: Array = []

func _ready() -> void:
	for spawner in self.get_children():
		spawn_locations.append(spawner)

func _spawn_enemies(mobs: Dictionary):	
	if mobs.has("Goblins"):
		var goblin_amount = mobs["Goblins"]
		for i in goblin_amount:
			for spawn in spawn_locations:
				await get_tree().create_timer(0.5).timeout
				_spawn_goblin(spawn.global_position)


# Spawn Enemies
# _create() parameters are: HP, Attack Damage, Attack Speed, Armor, Max Speed, Acceleration, Attack Size, Monster Type

func _spawn_goblin(location: Vector2):
	var goblin = Monster._create(20, 10, 1, 0, 200, 100, 1, "Goblin")
	goblin.global_position = location
	get_node("../Enemies").add_child(goblin)
