package main

import "core:fmt"
import "core:math"
import rl "vendor:raylib"


params: Params
editing_index: i8 = -1

SPEED :: 0.5

POINT_COUNT :: 20_000

camera: rl.Camera2D

angle: f32 = 0
points: [POINT_COUNT]rl.Vector2
points_cursor: i32 = 0

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
	params = params_init()
	camera = camera_init(&params)
}


update :: proc() {
	if params_update(&params) {
		camera = camera_init(&params)
		points_cursor = 0
	}
	camera_update(&camera, &params)

	angle -= SPEED * math.PI * 2 * rl.GetFrameTime()
}


render :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)
	defer rl.EndDrawing()

	rl.BeginMode2D(camera)
	{
		rl.DrawCircleLines(0, 0, auto_cast params.r1, rl.GRAY)

		render_gear(&params)

		rl.DrawLineStrip(&points[0], points_cursor, rl.VIOLET)
	}
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
