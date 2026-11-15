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
	}
]

func _process(delta: float) -> void:
	if (Globals.total_enemy_count - Globals.enemies_slain) > 0:
		UI.get_node("EnemiesLeft").text = "Enemies Left: " + str(Globals.total_enemy_count - Globals.enemies_slain)


func _ready() -> void:
	SignalBus.wave_completed.connect(_wave_completed)
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
	print("begin next")
	Globals.current_wave += 1
	Globals.total_enemy_count = enemy_waves[Globals.current_wave]["Total Enemies"]
	UI.get_node("WaveCounter").text = "Current Wave: " + str(Globals.current_wave)
	UI.get_node("WaveCounter").show()
	UI.get_node("NextWave").hide()
	spawner._spawn_enemies(enemy_waves[Globals.current_wave])

# I want Levels to pass dict values solely, move the above code somewhere reusable
