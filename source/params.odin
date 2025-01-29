package main

Params :: struct {
	r1:   i32,
	r2:   i32,
	r3:   i32,
	hash: i32,
}

params_init :: proc() -> Params {
	params := Params {
		r1 = 96,
		r2 = 57,
		r3 = 50,
	}
	params.hash = get_hash(&params)
	return params
}

// Returns true when the params have changed since the last frame.
params_update :: proc(params: ^Params) -> bool {
	new_params_hash := get_hash(params)

	if params.hash != new_params_hash {
		params.hash = new_params_hash
		return true
	}

	return false
}

@(private = "file")
get_hash :: proc(params: ^Params) -> i32 {
	return params.r1 * 1_000_000 + params.r2 * 1_000 + params.r3
}
