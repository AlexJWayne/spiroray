package main

import "core:math"
import rl "vendor:raylib"

render_gear :: proc(params: ^Params) {
	r1 := params.r1
	r2 := params.r2
	r3 := params.r3

	center := rl.Vector2Rotate(rl.Vector2{0, auto_cast (r1 - r2)}, angle)
	rl.DrawCircleLinesV(center, auto_cast r2, rl.GRAY)

	gear_angle := get_inner_gear_angle(params)

	gear_render_center_line(center, r2, gear_angle)
	gear_render_center_line(center, r2, gear_angle + math.PI / 2)

	point := center + rl.Vector2Rotate(rl.Vector2{auto_cast r3, 0}, gear_angle)
	points[points_cursor] = point
	points_cursor += 1
	if points_cursor >= POINT_COUNT {points_cursor = 0}

	rl.DrawCircleV(point, 1, rl.WHITE)
}

@(private = "file")
get_center :: proc(params: ^Params) -> rl.Vector2 {
	r: f32 = auto_cast (params.r1 - params.r2)
	return rl.Vector2Rotate(rl.Vector2{0, r}, angle)
}

@(private = "file")
get_inner_gear_angle :: proc(params: ^Params) -> f32 {
	return angle * (1 - (cast(f32)params.r1 / cast(f32)params.r2))
}

@(private = "file")
gear_render_center_line :: proc(center: rl.Vector2, r2: i32, gear_angle: f32) {
	rl.DrawLineV(
		center - rl.Vector2Rotate(rl.Vector2{auto_cast r2 * 0.2, 0}, gear_angle),
		center + rl.Vector2Rotate(rl.Vector2{auto_cast r2 * 0.2, 0}, gear_angle),
		rl.DARKGRAY,
	)
}
