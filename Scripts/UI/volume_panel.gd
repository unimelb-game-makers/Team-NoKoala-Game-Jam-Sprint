extends PanelContainer

const MUSIC_BUS: StringName = &"Music"
const SFX_BUS: StringName = &"SFX"

@onready var music_label: Label = $VBoxContainer/MusicLabel
@onready var music_slider: HSlider = $VBoxContainer/MusicSlider

@onready var sfx_label: Label = $VBoxContainer/SFXLabel
@onready var sfx_slider: HSlider = $VBoxContainer/SFXSlider


func _ready() -> void:
	_configure_slider(music_slider)
	_configure_slider(sfx_slider)

	music_slider.value = _get_bus_volume(MUSIC_BUS)
	sfx_slider.value = _get_bus_volume(SFX_BUS)

	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)

	_update_labels()


func _configure_slider(slider: HSlider) -> void:
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01


func _on_music_changed(value: float) -> void:
	_set_bus_volume(MUSIC_BUS, value)
	_update_labels()


func _on_sfx_changed(value: float) -> void:
	_set_bus_volume(SFX_BUS, value)
	_update_labels()


func _set_bus_volume(bus_name: StringName, value: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)

	if bus_index == -1:
		push_warning("Audio bus does not exist: %s" % bus_name)
		return

	value = clampf(value, 0.0, 1.0)

	AudioServer.set_bus_volume_linear(bus_index, value)
	AudioServer.set_bus_mute(bus_index, value <= 0.001)


func _get_bus_volume(bus_name: StringName) -> float:
	var bus_index := AudioServer.get_bus_index(bus_name)

	if bus_index == -1:
		push_warning("Audio bus does not exist: %s" % bus_name)
		return 1.0

	if AudioServer.is_bus_mute(bus_index):
		return 0.0

	return clampf(
		AudioServer.get_bus_volume_linear(bus_index),
		0.0,
		1.0
	)


func _update_labels() -> void:
	music_label.text = "Music: %d%%" % roundi(
		music_slider.value * 100.0
	)

	sfx_label.text = "SFX: %d%%" % roundi(
		sfx_slider.value * 100.0
	)
