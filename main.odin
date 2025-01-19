package main

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

R1 :: 80
R2 :: 57
R3 :: 50
SPEED :: 0.5

POINT_COUNT :: 20_000

camera: rl.Camera2D

points: [POINT_COUNT]rl.Vector2
points_cursor := 0

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
	camera = rl.Camera2D {
		offset   = rl.Vector2 {
			auto_cast rl.GetScreenWidth() / 2,
			auto_cast rl.GetScreenHeight() / 2,
		},
		target   = rl.Vector2{0, 0},
		rotation = 0,
		zoom     = auto_cast rl.GetScreenWidth() / R1 * 0.4,
	}
}

angle: f32 = 0

update :: proc() {
	angle -= SPEED * math.PI * 2 * rl.GetFrameTime()
}


render :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)
	defer rl.EndDrawing()


	rl.BeginMode2D(camera)
	{
		rl.DrawCircleLines(0, 0, R1, rl.GRAY)

		render_gear(R1, R2, R3, angle)

		rl.DrawLineStrip(&points[0], auto_cast points_cursor, rl.VIOLET)
	}
	rl.EndMode2D()

	render_stats()
}

render_gear :: proc(r1: f32, r2: f32, r3: f32, theta: f32) {
	center := rl.Vector2Rotate(rl.Vector2{0, r1 - r2}, angle)
	rl.DrawCircleLinesV(center, r2, rl.GRAY)

	gear_angle := angle * (1 - (r1 / r2))

	rl.DrawLineV(
		center - rl.Vector2Rotate(rl.Vector2{r2 * 0.2, 0}, gear_angle),
		center + rl.Vector2Rotate(rl.Vector2{r2 * 0.2, 0}, gear_angle),
		rl.RED,
	)

	rl.DrawLineV(
		center - rl.Vector2Rotate(rl.Vector2{r2 * 0.2, 0}, gear_angle + math.PI / 2),
		center + rl.Vector2Rotate(rl.Vector2{r2 * 0.2, 0}, gear_angle + math.PI / 2),
		rl.GREEN,
	)

	point := center + rl.Vector2Rotate(rl.Vector2{r3, 0}, gear_angle)
	points[points_cursor] = point
	points_cursor += 1
	if points_cursor >= POINT_COUNT {points_cursor = 0}

	rl.DrawCircleV(point, 1, rl.WHITE)
}

render_stats :: proc() {
	rl.DrawText(fmt.ctprintf("R1: %1.d", R1), 40, 40, 20, rl.GRAY)
	rl.DrawText(fmt.ctprintf("R2: %1.d", R2), 40, 60, 20, rl.GRAY)
	rl.DrawText(fmt.ctprintf("R3: %1.d", R3), 40, 80, 20, rl.GRAY)
}
