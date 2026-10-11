extends Node
## HighScores — autoload singleton.
## Persists the top 10 scores to user://highscores.json.
## Register in Project Settings > Autoload as "HighScores".

const SAVE_PATH : String = "user://highscores.json"
const MAX_ENTRIES : int = 10

## Each entry: { "name": String, "score": int }
var entries: Array = []

func _ready() -> void:
	_load()

func qualifies(score: int) -> bool:
	if entries.size() < MAX_ENTRIES:
		return true
	return score > int(entries[entries.size() - 1]["score"])

func submit(player_name: String, score: int) -> void:
	# Always store as int so JSON never writes decimals
	entries.append({"name": player_name.strip_edges(), "score": int(score)})
	entries.sort_custom(func(a, b): return int(a["score"]) > int(b["score"]))
	if entries.size() > MAX_ENTRIES:
		entries.resize(MAX_ENTRIES)
	_save()

func _save() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(entries))

func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var result: Variant = JSON.parse_string(file.get_as_text())
	if result is Array:
		entries = result as Array
