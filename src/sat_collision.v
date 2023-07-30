module pcoll2d

import artemkakun.trnsfrm2d
import math

// check_collision checks if to polygons collide.
// ATTENTION! Since the SAT algorithm is used, the polygons must be convex.
pub fn check_collision(first_polygon_points []trnsfrm2d.Position, second_polygon_points []trnsfrm2d.Position) bool {
	return collides_on_all_axes(first_polygon_points, second_polygon_points)
		&& collides_on_all_axes(second_polygon_points, first_polygon_points)
}

[inline]
fn collides_on_all_axes(polygon_points []trnsfrm2d.Position, another_polygon_points []trnsfrm2d.Position) bool {
	polygon_points_count := polygon_points.len

	for point_index in 0 .. polygon_points_count {
		normal := calculate_normal(polygon_points, point_index, polygon_points_count)

		polygon_on_normal_min, polygon_on_normal_max := project_polygon_on_axis(polygon_points,
			normal)

		another_polygon_on_normal_min, another_polygon_on_normal_max := project_polygon_on_axis(another_polygon_points,
			normal)

		if polygon_on_normal_max < another_polygon_on_normal_min
			|| another_polygon_on_normal_max < polygon_on_normal_min {
			return false
		}
	}

	return true
}

[direct_array_access; inline]
fn calculate_normal(polygon_points []trnsfrm2d.Position, point_index int, polygon_points_count int) trnsfrm2d.Vector {
	// HACK:
	// The expression next_vertex_index = (point_index + 1) % polygon_points.len is used to ensure
	// that we correctly cycle around the vertices of the polygon when we're calculating the edges.
	// In a polygon with n vertices, the edges are formed by pairs of vertices:
	// (0,1),(1,2),(2,3),…,(n−2,n−1),(n−1,0)(0,1),(1,2),(2,3),…,(n−2,n−1),(n−1,0).
	// The last pair, (n−1,0)(n−1,0), closes the polygon by connecting the last vertex with the first one.
	// The modulus operation (%) gives the remainder of the division.
	// When the index point_index reaches the end of the list (i.e., point_index becomes n-1),
	// point_index + 1 would be n, which is out of bounds for the list of vertices.
	// By doing (point_index + 1) % polygon_points.len, we ensure that the result wraps around to
	// 0 when point_index is n-1. So, next_vertex_index becomes 0 when point_index is n-1,
	// giving us the last pair (n−1,0)(n−1,0) and ensuring that we correctly cycle around the polygon.
	next_vertex_index := (point_index + 1) % polygon_points_count

	first_edge_point := polygon_points[point_index]
	second_edge_point := polygon_points[next_vertex_index]

	edge := trnsfrm2d.Vector{
		x: second_edge_point.x - first_edge_point.x
		y: second_edge_point.y - first_edge_point.y
	}

	return trnsfrm2d.Vector{
		x: -edge.y
		y: edge.x
	}
}

[inline]
fn project_polygon_on_axis(polygon_points []trnsfrm2d.Position, normal trnsfrm2d.Vector) (f64, f64) {
	// NOTE: We can use Optional type here and this will be logically correct.
	// However, this will lead to overhead (this is true for V 0.4.0 8735694) and slow down the function
	// almost twice on TCC (760ns for optional vs 490ns for infinity trick).
	mut min_dot_product := math.inf(1)
	mut max_dot_product := math.inf(-1)

	for point in polygon_points {
		dot_product := (point.x * normal.x + point.y * normal.y)

		if dot_product < min_dot_product {
			min_dot_product = dot_product
		}

		if dot_product > max_dot_product {
			max_dot_product = dot_product
		}
	}

	return min_dot_product, max_dot_product
}
