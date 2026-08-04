extends AudioStreamPlayer2D

const LEVEL_MUSIC := {
    &"title_screen": preload("res://Audio/Main menu theme.wav"),
    &"default": preload("res://Audio/Main theme.wav"),
}

func _ready() -> void:
    self.bus = &"Music"

    get_tree().scene_changed.connect(_play_current_scene_music)
    call_deferred("_play_current_scene_music")

func _play_current_scene_music() -> void:
    var current_scene := get_tree().current_scene

    if current_scene == null:
        return

    # Example: res://levels/level_1.tscn -> "level_1"
    var filename := current_scene.scene_file_path.get_file()
    var level_name := StringName(filename.get_basename())

    play_for_level(level_name)

func play_for_level(level_name: StringName) -> void:
    var next_music := LEVEL_MUSIC.get(level_name) as AudioStream

    if next_music == null:
        push_warning("No music configured for level: %s" % level_name)
        next_music = LEVEL_MUSIC.get(&"default")

    if stream == next_music and playing:
        return

    stream = next_music
    play()


func stop_music() -> void:
    stop()
    stream = null