extends Marker2D

signal puzzle_solved
signal puzzle_failed

@export var target_score: int = 1
@export var debug_puzzle: bool = false

var score: int

@onready var success_sfx: AudioStreamPlayer2D = $SuccessSFX

func _ready() -> void:
	for child in get_children():
		if child is Switch:
			child.debug = debug_puzzle
			child.switch_activated.connect(on_switch_activated)
			child.switch_deactivated.connect(on_switch_deactivated)

func on_switch_activated(switch: Switch):
	if switch.part_of_solution:
		increase_score()
	else:
		decrease_score()

func on_switch_deactivated(switch: Switch):
	if switch.part_of_solution:
		decrease_score()
	else:
		increase_score()

func increase_score():
	score += 1
	
	if score >= target_score:
		puzzle_solved.emit()
		if is_instance_valid(success_sfx):
			success_sfx.play()
			await success_sfx.finished
			success_sfx.queue_free()

func decrease_score():
	score -= 1
	
	if score < target_score:
		puzzle_failed.emit()
