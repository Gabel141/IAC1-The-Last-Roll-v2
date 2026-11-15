extends Node2D

@onready var spawner: Node2D = $EnemySpawner
@onready var UI: CanvasLayer = $"/root/Ui"

var enemy_waves: Array = [
	{
		"Total Enemies": 0,
		"Goblins": 0
	},
	{
		"Total Enemies": 10,
		"Goblins": 5
	},
	{
		"Total Enemies": 20,
		"Goblins": 10
	},
	{
		"Total Enemies": 30,
		"Goblins": 15
	},
	{
		"Total Enemies": 40,
		"Goblins": 20
	}
]

var is_player_dead = false

func _process(delta: float) -> void:
	if (Globals.total_enemy_count - Globals.enemies_slain) > 0:
		UI.get_node("EnemiesLeft").text = "Enemies Left: " + str(Globals.total_enemy_count - Globals.enemies_slain)


func _ready() -> void:
	SignalBus.wave_completed.connect(_wave_completed)
	SignalBus.player_died.connect(_player_died)
	if UI:
		UI.get_node("NextWave").text = "Start?"
		UI.get_node("NextWave").connect("pressed", _start_game)

func _start_game():
	print("game start")
	_begin_next_wave()
	UI.get_node("NextWave").disconnect("pressed", _start_game)
	UI.get_node("NextWave").connect("pressed", _begin_next_wave)
	UI.get_node("NextWave").text = "Next Wave?"

func _wave_completed():
	UI.get_node("EnemiesLeft").text = "Wave Completed"
	UI.get_node("NextWave").show()


func _begin_next_wave():
	if is_player_dead:
		UI.get_node("NextWave").text = "Start?"
		UI.get_node("NextWave").connect("pressed", _start_game)
		UI.get_node("WaveCounter").hide()
		UI.get_node("Dashes").show()
		Globals.current_wave = 0
		Globals.total_enemies_slain = 0
		Globals.total_enemy_count = 0
		Globals.enemies_slain = 0
		get_tree().reload_current_scene()


	else:
		print("begin next")
		Globals.current_wave += 1
		Globals.total_enemy_count = enemy_waves[Globals.current_wave]["Total Enemies"]
		UI.get_node("WaveCounter").text = "Current Wave: " + str(Globals.current_wave)
		UI.get_node("WaveCounter").show()
		UI.get_node("NextWave").hide()
		spawner._spawn_enemies(enemy_waves[Globals.current_wave])


func _player_died():
	is_player_dead = true
	UI.get_node("Health").text = "Player has died!"
	UI.get_node("Dashes").hide()
	UI.get_node("NextWave").text = "Play Again?"
	UI.get_node("NextWave").show()
	UI.get_node("WaveCounter").hide()
# I want Levels to pass dict values solely, move the above code somewhere reusable
