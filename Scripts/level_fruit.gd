extends Area2D

@export var bugged_texture: Texture2D
@export var grayscale_shader: ShaderMaterial
@export var fruit_level_scene: PackedScene
@export var camera: Camera2D
@export var fade_colour: Color
@export var fruit_id: String

@onready var sprite: Sprite2D = $Pivot/Sprite2D
@onready var pivot: Node2D = $Pivot

var isActive: bool = false
var isBugged: bool = false

var default_camera_position: Vector2 = Vector2.ZERO
var default_camera_zoom: Vector2

func _ready() -> void:
	sprite.material = grayscale_shader
	grayscale_shader.set_shader_parameter("gray_amount", 1.0)
	
	if default_camera_position == Vector2.ZERO:
		default_camera_position = camera.global_position
		default_camera_zoom = camera.zoom
	
	# only on return
	if TransitionLayer.zoom_target != Vector2.ZERO and TransitionLayer.zoom_fruit_id == fruit_id:
		reload_scene()
	
	if ProgressState.is_unlocked(fruit_id):
		set_active()
	if ProgressState.is_completed(fruit_id):
		set_bugged()

func _on_mouse_entered() -> void:
	if isActive:
		get_parent().register_hover(self)

func _on_mouse_exited() -> void:
	if (isActive):
		get_parent().unregister_hover(self)

func set_hovered(is_hovered: bool) -> void:
	var tween = create_tween()
	if (is_hovered):
		tween.tween_property(pivot, "scale", Vector2(1.1, 1.1), 0.15)
	else:
		tween.tween_property(pivot, "scale", Vector2(1.0, 1.0), 0.15)

func set_active() -> void:
	grayscale_shader.set_shader_parameter("gray_amount", 0.0)
	isActive = true
	
func set_bugged() -> void:
	sprite.texture = bugged_texture
	isBugged = true
	
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# placeholder for actual 'activate' functionality
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and isActive:
		# uncomment for debugging out of order tests
		#if !isActive:
			#TransitionLayer.active_fruits[fruit_id] = true
			#set_active()
		
		load_level()

func load_level() -> void:
	# store data
	TransitionLayer.zoom_target = $CollisionShape2D.global_position
	TransitionLayer.zoom_colour = fade_colour
	TransitionLayer.fade_rect.color = fade_colour
	TransitionLayer.zoom_amount = Vector2(4, 4)
	TransitionLayer.zoom_fruit_id = fruit_id
	
	# zoom camera
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(camera, "zoom", TransitionLayer.zoom_amount, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(camera, "global_position", TransitionLayer.zoom_target, 1.0).set_ease(Tween.EASE_IN)
	tween.tween_property(TransitionLayer.fade_rect, "modulate:a", 1.0, 0.4).set_delay(0.6)
	
	await tween.finished
	
	# change scene
	if (fruit_level_scene):
			get_tree().change_scene_to_packed(fruit_level_scene)
	
	await TransitionLayer.get_tree().process_frame
	await TransitionLayer.fade_in()

func reload_scene() -> void:
	var target = TransitionLayer.zoom_target
	var amount = TransitionLayer.zoom_amount
	TransitionLayer.zoom_target = Vector2.ZERO
	
	camera.zoom = amount
	camera.global_position = target
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(camera, "zoom", default_camera_zoom, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "global_position", default_camera_position, 1.0).set_ease(Tween.EASE_OUT)
