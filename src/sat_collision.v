module pcoll2d

import artemkakun.trnsfrm2d
import arrays

pub fn check_collision(first_polygon_points []trnsfrm2d.Position, second_polygon_points []trnsfrm2d.Position) !bool {
	polygons := [first_polygon_points, second_polygon_points]

	for polygon in polygons {
		for point_index in 0 .. polygon.len {
			// Sure! The expression i2 = (i1 + 1) % len(polygon) is used to ensure that we correctly cycle around the vertices of the polygon when we're calculating the edges.
			// In a polygon with nn vertices, the edges are formed by pairs of vertices: (0,1),(1,2),(2,3),…,(n−2,n−1),(n−1,0)(0,1),(1,2),(2,3),…,(n−2,n−1),(n−1,0). The last pair, (n−1,0)(n−1,0), closes the polygon by connecting the last vertex with the first one.
			// The modulus operation (%) in Python gives the remainder of the division. When the index i1 reaches the end of the list (i.e., i1 becomes n-1), i1 + 1 would be n, which is out of bounds for the list of vertices. By doing (i1 + 1) % len(polygon), we ensure that the result wraps around to 0 when i1 is n-1. So, i2 becomes 0 when i1 is n-1, giving us the last pair (n−1,0)(n−1,0) and ensuring that we correctly cycle around the polygon.
			// So, i2 = (i1 + 1) % len(polygon) is a neat Python trick that allows us to iterate over pairs of vertices in a cyclic manner.
			next_vertex_index := (point_index + 1) % polygon.len

			p1 := polygon[point_index]
			p2 := polygon[next_vertex_index]

			edge := trnsfrm2d.Vector{
				x: p2.x - p1.x
				y: p2.y - p1.y
			}

			normal := trnsfrm2d.Vector{
				x: -edge.y
				y: edge.x
			}

			min1, max1 := project_polygon(first_polygon_points, normal)!
			min2, max2 := project_polygon(second_polygon_points, normal)!

			if max1 < min2 || max2 < min1 {
				return false
			}
		}
	}

	return true
}

fn project_polygon(polygon_points []trnsfrm2d.Position, normal trnsfrm2d.Vector) !(f64, f64) {
	mut dot_products := []f64{}

	for point in polygon_points {
		dot_products << (point.x * normal.x + point.y * normal.y)
	}

	return arrays.min[f64](dot_products)!, arrays.max[f64](dot_products)!
}
