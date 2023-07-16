module pcoll2d

import artemkakun.trnsfrm2d

fn test_triangles_collide() {
	first_triangle_points := [trnsfrm2d.Position{
		x: 0
		y: 0
	}, trnsfrm2d.Position{
		x: 1
		y: 1
	}, trnsfrm2d.Position{
		x: 2
		y: 0
	}]

	second_triangle_points := [trnsfrm2d.Position{
		x: 1.5
		y: 0
	}, trnsfrm2d.Position{
		x: 1.5
		y: 1
	}, trnsfrm2d.Position{
		x: 2.5
		y: 0
	}]

	assert check_collision(first_triangle_points, second_triangle_points)!
}

fn test_triangles_touch_collide() {
	first_triangle_points := [trnsfrm2d.Position{
		x: 0
		y: 0
	}, trnsfrm2d.Position{
		x: 1
		y: 1
	}, trnsfrm2d.Position{
		x: 2
		y: 0
	}]

	second_triangle_points := [trnsfrm2d.Position{
		x: 0
		y: 1
	}, trnsfrm2d.Position{
		x: 1
		y: 2
	}, trnsfrm2d.Position{
		x: 2
		y: 1
	}]

	assert check_collision(first_triangle_points, second_triangle_points)!
}

fn test_negative_coordinates_triangles_collide() {
	first_triangle_points := [trnsfrm2d.Position{
		x: -1
		y: 0
	}, trnsfrm2d.Position{
		x: 0
		y: 1
	}, trnsfrm2d.Position{
		x: 1
		y: 0
	}]

	second_triangle_points := [trnsfrm2d.Position{
		x: 0
		y: 0
	}, trnsfrm2d.Position{
		x: 1
		y: 1
	}, trnsfrm2d.Position{
		x: 2
		y: 0
	}]

	assert check_collision(first_triangle_points, second_triangle_points)!
}

fn test_triangles_not_collide() {
	first_triangle_points := [trnsfrm2d.Position{
		x: 0
		y: 0
	}, trnsfrm2d.Position{
		x: 1
		y: 1
	}, trnsfrm2d.Position{
		x: 2
		y: 0
	}]

	second_triangle_points := [trnsfrm2d.Position{
		x: 2.1
		y: 0
	}, trnsfrm2d.Position{
		x: 2.1
		y: 1
	}, trnsfrm2d.Position{
		x: 3.1
		y: 0
	}]

	assert check_collision(first_triangle_points, second_triangle_points)! == false
}
