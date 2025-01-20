package main

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

@(private = "file")
camera: rl.Camera2D

@(private = "file")
params: Params

@(private = "file")
gear: Gear

@(private = "file")
angle: f32 = 0

@(private = "file")
editing_index: i8 = -1

@(private = "file")
SPEED :: 0.5


main :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
	rl.InitWindow(1024, 1024, "SpiroRay")
	defer rl.CloseWindow()
	rl.GuiLoadStyle("./style_dark.rgs")

	init()

	for !rl.WindowShouldClose() {
		update()
		render()
	}
}

init :: proc() {
	camera = camera_init()
	params = params_init()
	gear = gear_init()
}

update :: proc() {
	if params_update(&params) {gear.traced_point_index = 0}
	camera_update(&camera, &params)

	angle -= SPEED * math.PI * 2 * rl.GetFrameTime()
	gear_update(&gear, &params, angle)
}


render :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)
	defer rl.EndDrawing()

	rl.BeginMode2D(camera)
	gear_render(&gear, &params)
	rl.EndMode2D()

	render_input(1, "R1 ", &params.r1, 0, 100)
	render_input(2, "R2 ", &params.r2, 0, 100)
	render_input(3, "R3 ", &params.r3, 0, 100)
}


render_input :: proc(y: u8, label: cstring, value: ^i32, min: i32, max: i32) {
	clicked := rl.GuiSpinner(
		rl.Rectangle{50, 30 * auto_cast y, 100, 20},
		label,
		value,
		min,
		max,
		y == auto_cast editing_index,
	)
	if clicked > 0 {editing_index = auto_cast y}
}
