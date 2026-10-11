extends Control
## OptionsPanel — reusable options overlay with Music and SFX volume sliders.
## Instance this scene inside MainMenu and PauseMenu, hidden by default.
## Call show_panel() / hide_panel() from the parent script.

const SETTINGS_PATH := "user://settings.cfg"
const MUSIC_BUS     := "Music"
const SFX_BUS       := "SFX"

@onready var music_slider : HSlider = $PanelContainer/VBox/MusicRow/MusicSlider
@onready var sfx_slider   : HSlider = $PanelContainer/VBox/SFXRow/SFXSlider
@onready var close_button : Button  = $PanelContainer/VBox/CloseButton

func _ready() -> void:
	_ensure_buses()
	_load_settings()
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	close_button.pressed.connect(SFX.play_click)
	close_button.pressed.connect(hide_panel)
	hide()

func show_panel() -> void:
	show()
	close_button.grab_focus()

func hide_panel() -> void:
	hide()

func _ensure_buses() -> void:
	# Create Music and SFX buses if they don't exist yet
	if AudioServer.get_bus_index(MUSIC_BUS) == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, MUSIC_BUS)
		AudioServer.set_bus_send(AudioServer.bus_count - 1, "Master")
	if AudioServer.get_bus_index(SFX_BUS) == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, SFX_BUS)
		AudioServer.set_bus_send(AudioServer.bus_count - 1, "Master")

func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) == OK:
		music_slider.value = cfg.get_value("audio", "music_volume", 1.0)
		sfx_slider.value   = cfg.get_value("audio", "sfx_volume",   1.0)
	else:
		music_slider.value = 1.0
		sfx_slider.value   = 1.0
	_apply_music(music_slider.value)
	_apply_sfx(sfx_slider.value)

func _save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "music_volume", music_slider.value)
	cfg.set_value("audio", "sfx_volume",   sfx_slider.value)
	cfg.save(SETTINGS_PATH)

func _on_music_changed(value: float) -> void:
	_apply_music(value)
	_save_settings()

func _on_sfx_changed(value: float) -> void:
	_apply_sfx(value)
	_save_settings()

func _apply_music(value: float) -> void:
	var bus := AudioServer.get_bus_index(MUSIC_BUS)
	if bus != -1:
		AudioServer.set_bus_volume_db(bus, linear_to_db(value))
		AudioServer.set_bus_mute(bus, value == 0.0)

func _apply_sfx(value: float) -> void:
	var bus := AudioServer.get_bus_index(SFX_BUS)
	if bus != -1:
		AudioServer.set_bus_volume_db(bus, linear_to_db(value))
		AudioServer.set_bus_mute(bus, value == 0.0)
