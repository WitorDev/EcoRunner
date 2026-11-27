extends Node

const MENU_MUSIC_STREAM: AudioStream = preload("res://musica/Welcome to the Game.mp3")

var completed_tasks: int = 0
var total_tasks: int = 5
var is_game_finished: bool = false
var last_survival_time: float = 0.0
var menu_music_player: AudioStreamPlayer
const SCORE_FILE := "user://eco_runner_scores.cfg"
const MAX_SCORES := 5
var completion_times: Array[float] = []

signal tasks_progress_changed(completed: int, total: int)
signal game_finished


func _ready() -> void:
	_load_completion_times()


func _load_completion_times() -> void:
	var config := ConfigFile.new()
	if config.load(SCORE_FILE) != OK:
		return

	completion_times.clear()
	for index in range(MAX_SCORES):
		if config.has_section_key("scores", str(index)):
			var time_value: float = float(config.get_value("scores", str(index), 0.0))
			if time_value > 0.0:
				completion_times.append(time_value)
	completion_times.sort()


func register_completion_time(time_value: float) -> void:
	if time_value <= 0.0:
		return

	completion_times.append(time_value)
	completion_times.sort()
	if completion_times.size() > MAX_SCORES:
		completion_times.resize(MAX_SCORES)

	var config := ConfigFile.new()
	for index in completion_times.size():
		config.set_value("scores", str(index), completion_times[index])
	var error := config.save(SCORE_FILE)
	if error != OK:
		push_error("Não foi possível salvar as pontuações. Código: %s" % error)


func format_time(time_value: float) -> String:
	var total_seconds := int(time_value)
	var minutes := int(total_seconds / 60)
	var seconds := total_seconds % 60
	return "%02d:%02d" % [minutes, seconds]


func play_menu_music() -> void:
	if menu_music_player == null or not is_instance_valid(menu_music_player):
		menu_music_player = AudioStreamPlayer.new()
		menu_music_player.name = "MenuMusic"
		menu_music_player.stream = MENU_MUSIC_STREAM
		menu_music_player.finished.connect(_restart_menu_music)
		add_child(menu_music_player)

	if not menu_music_player.playing:
		menu_music_player.play()


func stop_menu_music() -> void:
	if menu_music_player == null or not is_instance_valid(menu_music_player):
		return

	menu_music_player.stop()
	menu_music_player.queue_free()
	menu_music_player = null


func _restart_menu_music() -> void:
	if menu_music_player != null and is_instance_valid(menu_music_player):
		menu_music_player.play()


func reset_progress() -> void:
	completed_tasks = 0
	is_game_finished = false
	tasks_progress_changed.emit(completed_tasks, total_tasks)


func set_total_tasks(value: int) -> void:
	total_tasks = max(1, value)
	if completed_tasks > total_tasks:
		completed_tasks = total_tasks
	is_game_finished = completed_tasks >= total_tasks
	if is_game_finished:
		game_finished.emit()
	tasks_progress_changed.emit(completed_tasks, total_tasks)


func update_progress(completed: int, total: int) -> void:
	total_tasks = max(1, total)
	completed_tasks = clamp(completed, 0, total_tasks)
	is_game_finished = completed_tasks >= total_tasks
	if is_game_finished:
		game_finished.emit()
	tasks_progress_changed.emit(completed_tasks, total_tasks)


func register_completed_task(task_name: String) -> void:
	if task_name.strip_edges() == "":
		return
	if completed_tasks >= total_tasks:
		return
	completed_tasks += 1
	is_game_finished = completed_tasks >= total_tasks
	if is_game_finished:
		game_finished.emit()
	tasks_progress_changed.emit(completed_tasks, total_tasks)


func get_progress_text() -> String:
	return "%d/%d" % [completed_tasks, total_tasks]
