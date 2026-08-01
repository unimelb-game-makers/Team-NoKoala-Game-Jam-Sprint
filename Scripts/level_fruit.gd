extends Area2D

@export var bugged_texture: Texture2D
@export var grayscale_shader: ShaderMaterial

@onready var sprite: Sprite2D = $Sprite2D

var isActive: bool = false
var isBugged: bool = false

func _ready() -> void:
	sprite.material = grayscale_shader
	grayscale_shader.set_shader_parameter("gray_amount", 1.0)

func _on_mouse_entered() -> void:
	if isActive:
		get_parent().register_hover(self)

func _on_mouse_exited() -> void:
	if (isActive):
		get_parent().unregister_hover(self)

func set_hovered(is_hovered: bool) -> void:
	var tween = create_tween()
	if (is_hovered):
		tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.15)
	else:
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)

func set_active() -> void:
	grayscale_shader.set_shader_parameter("gray_amount", 0.0)
	isActive = true
	
func set_bugged() -> void:
	sprite.texture = bugged_texture
	isBugged = true
	
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# placeholder for actual 'activate' functionality
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and !isActive:
		set_active()
