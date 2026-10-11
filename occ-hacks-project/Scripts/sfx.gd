extends Node
## SFX — autoload singleton for one-shot sound effects.
## Register in Project Settings > Autoload as "SFX".

const _CLICK_PATH     := "res://Assets/SFX/Button Click.wav"
const _OUT_TIME_PATH  := "res://Assets/SFX/Out Of Time.wav"

var _click_player    : AudioStreamPlayer
var _out_time_player : AudioStreamPlayer

func _ready() -> void:
	_click_player    = _make_player(_CLICK_PATH,    "SFX")
	_out_time_player = _make_player(_OUT_TIME_PATH, "SFX")

func _make_player(path: String, bus: String) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.stream = load(path)
	p.bus = bus
	p.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(p)
	return p

func play_click() -> void:
	_click_player.play()

func play_out_of_time() -> void:
	_out_time_player.play()
