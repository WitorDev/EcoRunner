extends Node

var completed_tasks: int = 0
var total_tasks: int = 5
var is_game_finished: bool = false
var last_survival_time: float = 0.0

signal tasks_progress_changed(completed: int, total: int)
signal game_finished


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
