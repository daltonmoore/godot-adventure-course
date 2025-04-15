extends StaticBody2D

class CancellationToken:
	var is_cancelled: bool = false

@export var dialog_lines: Array[String] = []

var can_interact: bool = false
var dialog_index: int = 0
var talking: bool = false
var cancellation_token: CancellationToken

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and can_interact:
		if talking and cancellation_token != null:
			cancellation_token.is_cancelled = true
			cancellation_token = null
			return
		
		
		if dialog_lines.size() > dialog_index:
			get_tree().paused = true
			$CanvasLayer/DialogLabel.text = ""
			$CanvasLayer.visible = true
			cancellation_token = CancellationToken.new()
			talk(dialog_lines[dialog_index], cancellation_token)
			dialog_index += 1
		else:
			get_tree().paused = false
			$CanvasLayer.visible = false
			dialog_index = 0
		
		print("Paused? %s" % $CanvasLayer.visible)
		

func talk(line: String, cancel_token: CancellationToken) -> void:
	talking = true
	if line.length() > 0:
		var c_index:int = 0
		var c:String = line[c_index]
		while c_index < line.length():
			if cancel_token.is_cancelled:
				break
			c = line[c_index]
			$CanvasLayer/DialogLabel.text += c
			$AudioStreamPlayer2D.play()
			$TalkSFXTimer.start()
			await $TalkSFXTimer.timeout
			c_index += 1
		if cancel_token.is_cancelled:
			$CanvasLayer/DialogLabel.text = line
		$TalkSFXTimer.stop()
	talking = false
