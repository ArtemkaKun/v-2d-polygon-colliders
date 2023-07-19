module pcoll2d

import artemkakun.trnsfrm2d

fn test_decompose_triangle_polygon() {
	polygon := [trnsfrm2d.Position{
		x: 0.0
		y: 0.0
	}, trnsfrm2d.Position{
		x: 1.0
		y: 1.0
	}, trnsfrm2d.Position{
		x: 2.0
		y: 0.0
	}]

	convex_polygons := decompose(polygon)

	assert convex_polygons.len == 1
	assert convex_polygons[0] == polygon
}

fn test_decompose_square_polygon() {
	polygon := [trnsfrm2d.Position{
		x: 0.0
		y: 0.0
	}, trnsfrm2d.Position{
		x: 0.0
		y: 1.0
	}, trnsfrm2d.Position{
		x: 1.0
		y: 1.0
	}, trnsfrm2d.Position{
		x: 1.0
		y: 0.0
	}]

	convex_polygons := decompose(polygon)

	assert convex_polygons.len == 1
	assert convex_polygons[0] == polygon
}

fn test_decompose_concave_polygon_1() {
	polygon := [trnsfrm2d.Position{
		x: 0.0
		y: 1.0
	}, trnsfrm2d.Position{
		x: 2.0
		y: 2.0
	}, trnsfrm2d.Position{
		x: 1.0
		y: 1.0
	}, trnsfrm2d.Position{
		x: 2.0
		y: 0.0
	}]

	convex_polygons := decompose(polygon)

	assert convex_polygons.len == 2

	assert convex_polygons[0] == [trnsfrm2d.Position{
		x: 1.0
		y: 1.0
	}, trnsfrm2d.Position{
		x: 2.0
		y: 0.0
	}, trnsfrm2d.Position{
		x: 0.0
		y: 1.0
	}]

	assert convex_polygons[1] == [trnsfrm2d.Position{
		x: 0.0
		y: 1.0
	}, trnsfrm2d.Position{
		x: 2.0
		y: 2.0
	}, trnsfrm2d.Position{
		x: 1.0
		y: 1.0
	}]
}

fn test_decompose_concave_polygon_2() {
	polygon := [trnsfrm2d.Position{
		x: -1.0
		y: 0.0
	}, trnsfrm2d.Position{
		x: -2.0
		y: 2.0
	}, trnsfrm2d.Position{
		x: 0.0
		y: 1.0
	}, trnsfrm2d.Position{
		x: 2.0
		y: 2.0
	}, trnsfrm2d.Position{
		x: 1.0
		y: 0.0
	}]

	convex_polygons := decompose(polygon)

	assert convex_polygons.len == 2

	assert convex_polygons[0] == [trnsfrm2d.Position{
		x: 0.0
		y: 1.0
	}, trnsfrm2d.Position{
		x: 2.0
		y: 2.0
	}, trnsfrm2d.Position{
		x: 1.0
		y: 0.0
	}]

	assert convex_polygons[1] == [trnsfrm2d.Position{
		x: 1.0
		y: 0.0
	}, trnsfrm2d.Position{
		x: -1.0
		y: 0.0
	}, trnsfrm2d.Position{
		x: -2.0
		y: 2.0
	}, trnsfrm2d.Position{
		x: 0.0
		y: 1.0
	}]
}

fn test_decompose_concave_polygon_3() {
	polygon := [trnsfrm2d.Position{
		x: -1.0
		y: 0.0
	}, trnsfrm2d.Position{
		x: -2.0
		y: 2.0
	}, trnsfrm2d.Position{
		x: -0.5
		y: 1.0
	}, trnsfrm2d.Position{
		x: 0.0
		y: 2.0
	}, trnsfrm2d.Position{
		x: 0.5
		y: 1.0
	}, trnsfrm2d.Position{
		x: 2.0
		y: 2.0
	}, trnsfrm2d.Position{
		x: 1.0
		y: 0.0
	}]

	convex_polygons := decompose(polygon)

	assert convex_polygons.len == 3

	assert convex_polygons[0] == [trnsfrm2d.Position{
		x: 0.5
		y: 1.0
	}, trnsfrm2d.Position{
		x: 2.0
		y: 2.0
	}, trnsfrm2d.Position{
		x: 1.0
		y: 0.0
	}]

	assert convex_polygons[1] == [trnsfrm2d.Position{
		x: 1.0
		y: 0.0
	}, trnsfrm2d.Position{
		x: -0.5
		y: 1.0
	}, trnsfrm2d.Position{
		x: 0.0
		y: 2.0
	}, trnsfrm2d.Position{
		x: 0.5
		y: 1.0
	}]

	assert convex_polygons[2] == [trnsfrm2d.Position{
		x: 1.0
		y: 0.0
	}, trnsfrm2d.Position{
		x: -1.0
		y: 0.0
	}, trnsfrm2d.Position{
		x: -2.0
		y: 2.0
	}, trnsfrm2d.Position{
		x: -0.5
		y: 1.0
	}]
}
