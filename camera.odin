package main

import rl "vendor:raylib"

camera_init :: proc(params: ^Params) -> rl.Camera2D {
	return rl.Camera2D {
		offset = rl.Vector2{0, 0},
		target = rl.Vector2{0, 0},
		rotation = 0,
		zoom = 1,
	}
}

camera_update :: proc(camera: ^rl.Camera2D, params: ^Params) {
	camera.offset = rl.Vector2 {
		auto_cast rl.GetScreenWidth() / 2, //
		auto_cast rl.GetScreenHeight() / 2,
	}

	screen := min(rl.GetScreenWidth(), rl.GetScreenHeight())
	camera.zoom = auto_cast screen / auto_cast params.r1 * 0.4
}
