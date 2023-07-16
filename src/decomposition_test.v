module pcoll2d

import artemkakun.trnsfrm2d

fn test_decompose_convex_polygon() {
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

	assert convex_polygons?.len == 1
	assert convex_polygons?[0] == polygon
}
