module pcoll2d

import artemkakun.trnsfrm2d

fn test_triangle_rectangle_collide() {
	triangle_points := [trnsfrm2d.Position{
		x: 0
		y: 0
	}, trnsfrm2d.Position{
		x: 1
		y: 1
	}, trnsfrm2d.Position{
		x: 2
		y: 0
	}]

	rectangle_points := [trnsfrm2d.Position{
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

	assert check_collision(triangle_points, rectangle_points)!
}

fn test_triangle_rectangle_touch_collide() {
	triangle_points := [trnsfrm2d.Position{
		x: 0
		y: 0
	}, trnsfrm2d.Position{
		x: 1
		y: 1
	}, trnsfrm2d.Position{
		x: 2
		y: 0
	}]

	rectangle_points := [trnsfrm2d.Position{
		x: 0
		y: 1
	}, trnsfrm2d.Position{
		x: 0
		y: 2
	}, trnsfrm2d.Position{
		x: 2
		y: 2
	}, trnsfrm2d.Position{
		x: 2
		y: 0
	}]

	assert check_collision(triangle_points, rectangle_points)!
}

fn test_triangle_rectangle_not_collide() {
	triangle_points := [trnsfrm2d.Position{
		x: 0
		y: 0
	}, trnsfrm2d.Position{
		x: 1
		y: 1
	}, trnsfrm2d.Position{
		x: 2
		y: 0
	}]

	rectangle_points := [trnsfrm2d.Position{
		x: 0
		y: 2
	}, trnsfrm2d.Position{
		x: 0
		y: 3
	}, trnsfrm2d.Position{
		x: 1
		y: 3
	}, trnsfrm2d.Position{
		x: 1
		y: 2
	}]

	assert check_collision(triangle_points, rectangle_points)! == false
}
