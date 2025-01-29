package main

import "core:math"
import rl "vendor:raylib"

@(private = "file")
POINT_COUNT :: 20000

@(private = "file")
SPEED :: 0.5

@(private = "file")
UPS :: 120

Gear :: struct {
	moving:             bool,
	center:             rl.Vector2,
	outer_angle:        f32,
	angle:              f32,
	started_at:         f32,
	traced_points:      [POINT_COUNT]rl.Vector2,
	traced_point_index: u16,
}

gear_init :: proc() -> Gear {
	return Gear {
		moving = true,
		outer_angle = 0,
		angle = 0,
		started_at = auto_cast rl.GetTime(),
		traced_point_index = 0,
	}
}

gear_update :: proc(gear: ^Gear, params: ^Params) {

	elapsed: f32 = auto_cast rl.GetTime()
	total_ticks := cast(u16)((elapsed - gear.started_at) * UPS)

	for _ in gear.traced_point_index ..= total_ticks {
		gear_tick(gear, params, elapsed)
	}
}

gear_tick :: proc(gear: ^Gear, params: ^Params, elapsed: f32) {
	if !gear.moving {return}


	gear.outer_angle -= SPEED * math.PI * 2 / UPS

	gear.center = get_center(params, gear.outer_angle)
	gear.angle = get_inner_gear_angle(params, gear.outer_angle)

	gear.traced_points[gear.traced_point_index] = get_traced_point(gear, params)
	gear.traced_point_index += 1

	if gear.traced_point_index >= POINT_COUNT {
		gear.moving = false
	}
}

gear_render :: proc(gear: ^Gear, params: ^Params) {
	r1 := cast(f32)params.r1
	r2 := cast(f32)params.r2

	render_perimeter(rl.Vector2{0, 0}, r1)

	if gear.moving {
		render_perimeter(gear.center, r2)
		render_center_line(gear.center, r2, gear.angle)
		render_center_line(gear.center, r2, gear.angle + math.PI / 2)
	}

	render_traced_path(gear)

	render_pen(gear)
}

@(private = "file")
get_center :: proc(params: ^Params, angle: f32) -> rl.Vector2 {
	r: f32 = auto_cast (params.r1 - params.r2)
	return rl.Vector2Rotate(rl.Vector2{0, r}, angle)
}

@(private = "file")
get_inner_gear_angle :: proc(params: ^Params, angle: f32) -> f32 {
	return angle * (1 - (cast(f32)params.r1 / cast(f32)params.r2))
}

@(private = "file")
get_traced_point :: proc(gear: ^Gear, params: ^Params) -> rl.Vector2 {
	pen_offset := rl.Vector2{auto_cast params.r3, 0}
	return gear.center + rl.Vector2Rotate(pen_offset, gear.angle)
}

@(private = "file")
render_perimeter :: proc(center: rl.Vector2, r: f32) {
	rl.DrawRing(
		center = center,
		innerRadius = r - 0.5,
		outerRadius = r + 0.5,
		startAngle = 0,
		endAngle = 360,
		segments = 128,
		color = rl.DARKGRAY,
	)
}

@(private = "file")
render_pen :: proc(gear: ^Gear) {
	rl.DrawCircleV(gear.traced_points[gear.traced_point_index - 1], 1, rl.WHITE)
}

@(private = "file")
render_center_line :: proc(center: rl.Vector2, r2: f32, gear_angle: f32) {
	rl.DrawLineV(
		center - rl.Vector2Rotate(rl.Vector2{r2 * 0.2, 0}, gear_angle),
		center + rl.Vector2Rotate(rl.Vector2{r2 * 0.2, 0}, gear_angle),
		rl.DARKGRAY,
	)
}

render_traced_path :: proc(gear: ^Gear) {
	rl.DrawLineStrip(&gear.traced_points[0], auto_cast gear.traced_point_index, rl.VIOLET)
}
