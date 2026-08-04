extends Node

const BUS_NAME: StringName = &"SFX"

const SOUNDS := {
	&"break_tiles": preload("res://Audio/Breaking tiles.wav"),
	&"star": preload("res://audio/Stars sfx.wav"),
	&"crawling": preload("res://audio/Caterpillar.wav"),
	&"button_click": preload("res://audio/button click.wav"),
	&'slug': preload("res://audio/temp_slug_sound.wav"),
	&'page_turn': preload("res://Audio/Page Turning Sfx.wav"),
	&'swish': preload("res://Audio/swish-2.wav"),
	&'ding': preload("res://Audio/completetask_0.mp3"),
	&'complete_level': preload("res://Audio/gmae.wav"),
	&'thump' : preload("res://Audio/thump_02.ogg"),
	&'crunch' : preload("res://Audio/whoosh.wav"),
	&'crunch_reverse' : preload("res://Audio/whoosh_reverse.wav"),
	&'reset' : preload("res://Audio/Punch2__007.ogg"),
	&'undo' : preload("res://Audio/Punch2__008.ogg")
}

var active_players: Array[AudioStreamPlayer] = []

func play_sfx(
	sound_name: StringName,
	volume_db: float = 0.0,
	pitch_scale: float = 1.0
) -> AudioStreamPlayer:
	var stream := SOUNDS.get(sound_name) as AudioStream

	if stream == null:
		push_warning("Unknown SFX: %s" % sound_name)
		return null

	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = BUS_NAME
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale	
	add_child(player)
	player.set_meta(&"sound_name", sound_name)
	active_players.append(player)

	player.finished.connect(_on_player_finished.bind(player))
	player.play()

	return player

func stop_all() -> void:
	for player in active_players:
		player.stop()
		player.queue_free()

	active_players.clear()

func stop(sound_name: StringName) -> void:
	for player in active_players.duplicate():
		if player.get_meta(&"sound_name", &"") == sound_name:
			active_players.erase(player)
			player.stop()
			player.queue_free()

func set_volume_db(volume_db: float) -> void:
	var bus_index := AudioServer.get_bus_index(BUS_NAME)

	if bus_index != -1:
		AudioServer.set_bus_volume_db(bus_index, volume_db)


func set_muted(muted: bool) -> void:
	var bus_index := AudioServer.get_bus_index(BUS_NAME)

	if bus_index != -1:
		AudioServer.set_bus_mute(bus_index, muted)

func _on_player_finished(player: AudioStreamPlayer) -> void:
	active_players.erase(player)
	player.queue_free()
