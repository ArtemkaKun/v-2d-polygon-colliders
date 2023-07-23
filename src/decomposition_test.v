module pcoll2d

import artemkakun.trnsfrm2d
import json

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

	convex_polygons := decomp_polygon(polygon)

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

	convex_polygons := decomp_polygon(polygon)

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

	convex_polygons := decomp_polygon(polygon)

	assert convex_polygons.len == 2

	assert convex_polygons[0] == [trnsfrm2d.Position{
		x: 0.0
		y: 1.0
	}, trnsfrm2d.Position{
		x: 1.0
		y: 1.0
	}, trnsfrm2d.Position{
		x: 2.0
		y: 0.0
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

	convex_polygons := decomp_polygon(polygon)

	assert convex_polygons.len == 2

	assert convex_polygons[0] == [trnsfrm2d.Position{
		x: -1.0
		y: 0.0
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

	assert convex_polygons[1] == [trnsfrm2d.Position{
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

	convex_polygons := decomp_polygon(polygon)

	assert convex_polygons.len == 3

	assert convex_polygons[0] == [trnsfrm2d.Position{
		x: -1.0
		y: 0.0
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

	assert convex_polygons[1] == [trnsfrm2d.Position{
		x: -1.0
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

fn test_one() {
	polygon_file := '{"points":[{"Vector":{"x":0.0,"y":4.05}},{"Vector":{"x":3.05,"y":3.1}},{"Vector":{"x":5.05,"y":1.0}},{"Vector":{"x":7.0,"y":1.0}},{"Vector":{"x":7.0,"y":3.0}},{"Vector":{"x":9.05,"y":3.0}},{"Vector":{"x":12.0,"y":3.0}},{"Vector":{"x":12.0,"y":2.05}},{"Vector":{"x":14.1,"y":0.0}},{"Vector":{"x":16.0,"y":0.0}},{"Vector":{"x":16.0,"y":4.05}},{"Vector":{"x":20.0,"y":4.05}},{"Vector":{"x":20.0,"y":13.1}},{"Vector":{"x":18.05,"y":14.0}},{"Vector":{"x":17.05,"y":15.95}},{"Vector":{"x":15.0,"y":18.0}},{"Vector":{"x":11.0,"y":17.95}},{"Vector":{"x":11.0,"y":19.0}},{"Vector":{"x":9.0,"y":21.0}},{"Vector":{"x":6.95,"y":21.0}},{"Vector":{"x":7.0,"y":17.05}},{"Vector":{"x":3.05,"y":17.05}},{"Vector":{"x":3.05,"y":18.0}},{"Vector":{"x":0.0,"y":18.05}}]}'

	polygon := json.decode(Polygon, polygon_file) or { panic(err) }

	println(decomp_polygon(polygon.points))
}
