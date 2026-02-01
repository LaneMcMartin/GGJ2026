## Class to display a number as a particle.
class_name NumberParticle
extends GPUParticles2D

const _1 = preload("uid://dru5dead0wo5j")
const _2 = preload("uid://b6yygrg6vpxsk")
const _3 = preload("uid://spssodookkos")
const HUE_SHIFT_MATERIAL = preload("uid://dj5g3bffvpah4")

func set_number(number: int) -> void:
	material = HUE_SHIFT_MATERIAL.duplicate()
	material.set_shader_parameter("hue_shift", PaletteTileMapLayer.GROUP_COLORS.get(number, 0))
	match number:
		1:
			texture = _1
		2:
			texture = _2
		3:
			texture = _3
		_:
			queue_free()
