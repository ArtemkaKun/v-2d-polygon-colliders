module pcoll2d

import artemkakun.trnsfrm2d

fn test_lines_collide() {
	first_line_points := [trnsfrm2d.Position{
		x: 0
		y: 0
	}, trnsfrm2d.Position{
		x: 1
		y: 1
	}]

	second_line_points := [trnsfrm2d.Position{
		x: 0
		y: 1
	}, trnsfrm2d.Position{
		x: 1
		y: 0
	}]

	assert check_collision(first_line_points, second_line_points)
}

fn test_lines_touch_collide() {
	first_line_points := [trnsfrm2d.Position{
		x: 0
		y: 0
	}, trnsfrm2d.Position{
		x: 1
		y: 1
	}]

	second_line_points := [trnsfrm2d.Position{
		x: 1
		y: 1
	}, trnsfrm2d.Position{
		x: 2
		y: 2
	}]

	assert check_collision(first_line_points, second_line_points)
}

fn test_negative_coordinates_lines_collide() {
	first_line_points := [trnsfrm2d.Position{
		x: 0
		y: 0
	}, trnsfrm2d.Position{
		x: -1
		y: -1
	}]

	second_line_points := [trnsfrm2d.Position{
		x: 0
		y: -1
	}, trnsfrm2d.Position{
		x: -1
		y: 0
	}]

	assert check_collision(first_line_points, second_line_points)
}

fn test_lines_not_collide() {
	first_line_points := [trnsfrm2d.Position{
		x: 0
		y: 0
	}, trnsfrm2d.Position{
		x: 1
		y: 1
	}]

	second_line_points := [trnsfrm2d.Position{
		x: 0
		y: 1
	}, trnsfrm2d.Position{
		x: -1
		y: 2
	}]

	assert check_collision(first_line_points, second_line_points) == false
}

fn test_parallel_lines_not_collide() {
	first_line_points := [trnsfrm2d.Position{
		x: 0
		y: 0
	}, trnsfrm2d.Position{
		x: 1
		y: 1
	}]

	second_line_points := [trnsfrm2d.Position{
		x: 0
		y: 1
	}, trnsfrm2d.Position{
		x: 1
		y: 2
	}]

	assert check_collision(first_line_points, second_line_points) == false
}

fn test_perpendicular_lines_not_collide() {
	first_line_points := [trnsfrm2d.Position{
		x: 0
		y: 0
	}, trnsfrm2d.Position{
		x: 0
		y: 1
	}]

	second_line_points := [trnsfrm2d.Position{
		x: 1
		y: 0.5
	}, trnsfrm2d.Position{
		x: 2
		y: 0.5
	}]

	assert check_collision(first_line_points, second_line_points) == false
}

fn test_very_close_lines_not_collide() {
	first_line_points := [trnsfrm2d.Position{
		x: 0
		y: 0
	}, trnsfrm2d.Position{
		x: 0
		y: 1
	}]

	second_line_points := [trnsfrm2d.Position{
		x: 0.00000001
		y: 0
	}, trnsfrm2d.Position{
		x: 0.00000001
		y: 1
	}]

	assert check_collision(first_line_points, second_line_points) == false
}
