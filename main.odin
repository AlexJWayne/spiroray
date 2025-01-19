package main

import "core:fmt"
import "core:math"
import rl "vendor:raylib"


Params :: struct {
	r1:   i32,
	r2:   i32,
	r3:   i32,
	hash: i32,
}
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

	init()

	for !rl.WindowShouldClose() {
		update()
		render()
	}
}

init :: proc() {
	params = Params {
		r1 = 96,
		r2 = 57,
		r3 = 50,
	}
	params.hash = get_params_hash()

	init_camera()

	rl.GuiLoadStyle("./style_dark.rgs")
}

init_camera :: proc() {
	camera = rl.Camera2D {
		offset   = rl.Vector2 {
			auto_cast rl.GetScreenWidth() / 2,
			auto_cast rl.GetScreenHeight() / 2,
		},
		target   = rl.Vector2{0, 0},
		rotation = 0,
		zoom     = auto_cast rl.GetScreenWidth() / auto_cast params.r1 * 0.4,
	}
}


update :: proc() {
	new_params_hash := get_params_hash()
	if params.hash != new_params_hash {
		init_camera()
		points_cursor = 0
		params.hash = new_params_hash
	}

	angle -= SPEED * math.PI * 2 * rl.GetFrameTime()
}


render :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)
	defer rl.EndDrawing()


	rl.BeginMode2D(camera)
	{
		rl.DrawCircleLines(0, 0, auto_cast params.r1, rl.GRAY)

		render_gear()

		rl.DrawLineStrip(&points[0], points_cursor, rl.VIOLET)
	}
	rl.EndMode2D()

	render_slider(1, "R1 ", &params.r1, 0, 100)
	render_slider(2, "R2 ", &params.r2, 0, 100)
	render_slider(3, "R3 ", &params.r3, 0, 100)
}

get_params_hash :: proc() -> i32 {
	return params.r1 * 1_000_000 + params.r2 * 1_000 + params.r3
}

render_gear :: proc() {
	r1 := params.r1
	r2 := params.r2
	r3 := params.r3

	center := rl.Vector2Rotate(rl.Vector2{0, auto_cast (r1 - r2)}, angle)
	rl.DrawCircleLinesV(center, auto_cast r2, rl.GRAY)

	gear_angle := angle * (1 - (cast(f32)r1 / cast(f32)r2))

	rl.DrawLineV(
		center - rl.Vector2Rotate(rl.Vector2{auto_cast r2 * 0.2, 0}, gear_angle),
		center + rl.Vector2Rotate(rl.Vector2{auto_cast r2 * 0.2, 0}, gear_angle),
		rl.DARKGRAY,
	)

	rl.DrawLineV(
		center - rl.Vector2Rotate(rl.Vector2{auto_cast r2 * 0.2, 0}, gear_angle + math.PI / 2),
		center + rl.Vector2Rotate(rl.Vector2{auto_cast r2 * 0.2, 0}, gear_angle + math.PI / 2),
		rl.DARKGRAY,
	)

	point := center + rl.Vector2Rotate(rl.Vector2{auto_cast r3, 0}, gear_angle)
	points[points_cursor] = point
	points_cursor += 1
	if points_cursor >= POINT_COUNT {points_cursor = 0}

	rl.DrawCircleV(point, 1, rl.WHITE)
}

render_slider :: proc(y: u8, label: cstring, value: ^i32, min: i32, max: i32) {
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
