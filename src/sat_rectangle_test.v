module pcoll2d

import artemkakun.trnsfrm2d

fn test_rectangles_collide() {
	first_rectangle_points := [trnsfrm2d.Position{
		x: 0
		y: 0
	}, trnsfrm2d.Position{
		x: 0
		y: 1
	}, trnsfrm2d.Position{
		x: 1
		y: 1
	}, trnsfrm2d.Position{
		x: 1
		y: 0
	}]

	second_rectangle_points := [trnsfrm2d.Position{
		x: 0
		y: 0
	}, trnsfrm2d.Position{
		x: 0
		y: 1
	}, trnsfrm2d.Position{
		x: 1
		y: 1
	}, trnsfrm2d.Position{
		x: 1
		y: 0
	}]

	assert check_collision(first_rectangle_points, second_rectangle_points)
}

fn test_rectangles_touch_collide() {
	first_rectangle_points := [trnsfrm2d.Position{
		x: 0
		y: 0
	}, trnsfrm2d.Position{
		x: 0
		y: 1
	}, trnsfrm2d.Position{
		x: 1
		y: 1
	}, trnsfrm2d.Position{
		x: 1
		y: 0
	}]

	second_rectangle_points := [trnsfrm2d.Position{
		x: 1
		y: 1
	}, trnsfrm2d.Position{
		x: 1
		y: 2
	}, trnsfrm2d.Position{
		x: 2
		y: 2
	}, trnsfrm2d.Position{
		x: 2
		y: 1
	}]

	assert check_collision(first_rectangle_points, second_rectangle_points)
}

fn test_negative_coordinates_rectangles_collide() {
	first_rectangle_points := [trnsfrm2d.Position{
		x: 0
		y: 0
	}, trnsfrm2d.Position{
		x: 0
		y: 1
	}, trnsfrm2d.Position{
		x: -1
		y: 1
	}, trnsfrm2d.Position{
		x: -1
		y: 0
	}]

	second_rectangle_points := [trnsfrm2d.Position{
		x: 0
		y: 0
	}, trnsfrm2d.Position{
		x: 0
		y: 1
	}, trnsfrm2d.Position{
		x: -1
		y: 1
	}, trnsfrm2d.Position{
		x: -1
		y: 0
	}]

	assert check_collision(first_rectangle_points, second_rectangle_points)
}

fn test_rectangles_not_collide() {
	first_rectangle_points := [trnsfrm2d.Position{
		x: 0
		y: 0
	}, trnsfrm2d.Position{
		x: 0
		y: 1
	}, trnsfrm2d.Position{
		x: 1
		y: 1
	}, trnsfrm2d.Position{
		x: 1
		y: 0
	}]

	second_rectangle_points := [trnsfrm2d.Position{
		x: 2
		y: 2
	}, trnsfrm2d.Position{
		x: 2
		y: 3
	}, trnsfrm2d.Position{
		x: 3
		y: 3
	}, trnsfrm2d.Position{
		x: 3
		y: 2
	}]

	assert check_collision(first_rectangle_points, second_rectangle_points) == false
}
