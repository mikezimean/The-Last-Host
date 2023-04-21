extends AudioStreamPlayer2D

@export var repeat_delay : float = 1
@export var repeat_delay_randomness : float = 0
@export var is_playing : bool = false
@export var repeats : bool = true

var _is_waiting : bool = false

func _ready():
	if is_playing:
		_play_loop(true)

func _play_loop(skip_first : bool = false):
	var skipped_first : bool = false
	while is_playing:
		if skip_first and not skipped_first:
			skipped_first = true
		else:
			play()
		_is_waiting = true
		var wait_time = repeat_delay + randf_range(-repeat_delay_randomness, repeat_delay_randomness)
		$Timer.start(wait_time)
		await $Timer.timeout
		_is_waiting = false
		if not repeats:
			return

func play_loop():
	if is_playing:
		return
	is_playing = true
	if _is_waiting:
		return
	_play_loop()

func stop_loop():
	is_playing = false
