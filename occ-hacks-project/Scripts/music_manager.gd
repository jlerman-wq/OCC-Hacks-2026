extends Node
## MusicManager — autoload singleton for background music.
## Register in Project Settings > Autoload as "MusicManager".

const TRACKS := {
	"menu":   "res://Assets/Music/Menu.wav",
	"level1": "res://Assets/Music/Level 1.wav",
	"level2": "res://Assets/Music/Level 2.wav",
	"level3": "res://Assets/Music/Level 3.wav",
}

var _player      : AudioStreamPlayer
var _current_key : String = ""

func _ready() -> void:
	_player              = AudioStreamPlayer.new()
	_player.bus          = "Music"
	_player.process_mode = Node.PROCESS_MODE_ALWAYS
	_player.volume_db    = 0.0
	add_child(_player)

func play(track_key: String) -> void:
	if track_key == _current_key and _player.playing:
		return
	var path: String = TRACKS.get(track_key, "")
	if path == "":
		push_warning("MusicManager: unknown track key '%s'" % track_key)
		return
	_current_key = track_key
	_player.stream = load(path)
	_player.play()

func stop() -> void:
	_current_key = ""
	_player.stop()
