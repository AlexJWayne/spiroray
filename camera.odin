package main

import rl "vendor:raylib"

@(private = "file")
ZOOM :: 0.4

camera_init :: proc() -> rl.Camera2D {
	return rl.Camera2D {
		offset = rl.Vector2{0, 0},
		target = rl.Vector2{0, 0},
		rotation = 0,
		zoom = 1,
	}
}

camera_update :: proc(camera: ^rl.Camera2D, params: ^Params) {
	r1: f32 = auto_cast params.r1
	w: f32 = auto_cast rl.GetScreenWidth()
	h: f32 = auto_cast rl.GetScreenHeight()

	camera.offset = rl.Vector2{w / 2, h / 2}

	screen := min(w, h)
	camera.zoom = screen / r1 * ZOOM
}
