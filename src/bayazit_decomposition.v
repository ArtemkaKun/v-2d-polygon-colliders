module pcoll2d

import artemkakun.trnsfrm2d

// def is_reflex(vertex, next_vertex, prev_vertex):
//    return (next_vertex[1] - vertex[1]) * (prev_vertex[0] - vertex[0]) < (next_vertex[0] - vertex[0]) * (prev_vertex[1] - vertex[1])
//
// def area(a, b, c):
//    return ((b[0] - a[0]) * (c[1] - a[1])) - ((b[1] - a[1]) * (c[0] - a[0]))
//
// def left(a, b, c):
//    return area(a, b, c) > 0
//
// def left_on(a, b, c):
//    return area(a, b, c) >= 0
//
// def right(a, b, c):
//    return area(a, b, c) < 0
//
// def right_on(a, b, c):
//    return area(a, b, c) <= 0
//
// def bayazit_decompose(polygon):
//    if len(polygon) < 3:
//        return []
//
//    size = len(polygon)
//    parts = []
//    reflex_vertices = []
//    for i in range(size):
//        prev_vertex = polygon[(i - 1) % size]
//        vertex = polygon[i]
//        next_vertex = polygon[(i + 1) % size]
//        if is_reflex(vertex, next_vertex, prev_vertex):
//            reflex_vertices.append(vertex)
//
//    upper_part = []
//    lower_part = []
//
//    min_left = None
//    min_bottom = None
//    min_i = None
//
//    for i, reflex_vertex in enumerate(reflex_vertices):
//        reflex_i = polygon.index(reflex_vertex)
//        for j in range(1, size - 1):
//            next_vertex = polygon[(reflex_i + j) % size]
//            if next_vertex in reflex_vertices:
//                continue
//            if left_on(reflex_vertex, polygon[(reflex_i - 1) % size], next_vertex) and right(reflex_vertex, polygon[(reflex_i + 1) % size], next_vertex):
//                if min_i is None or (next_vertex[1] < min_bottom or (next_vertex[1] == min_bottom and next_vertex[0] > min_left)):
//                    min_left = next_vertex[0]
//                    min_bottom = next_vertex[1]
//                    min_i = (reflex_i + j) % size
//                    upper_part = polygon[reflex_i:min_i+1] if reflex_i < min_i else (polygon[reflex_i:] + polygon[:min_i+1])
//                    lower_part = polygon[min_i:reflex_i+1] if min_i < reflex_i else (polygon[min_i:] + polygon[:reflex_i+1])
//
//    if min_i is None:
//        parts.append(polygon)
//    else:
//        parts.extend(bayazit_decompose(upper_part))
//        parts.extend(bayazit_decompose(lower_part))
//
//    return parts
//

fn is_reflect(vertex trnsfrm2d.Position, next_vertex trnsfrm2d.Position, prev_vertex trnsfrm2d.Position) bool {
	return (next_vertex.y - vertex.y) * (prev_vertex.x - vertex.x) < (next_vertex.x - vertex.x) * (prev_vertex.y - vertex.y)
}

fn area(a trnsfrm2d.Position, b trnsfrm2d.Position, c trnsfrm2d.Position) f64 {
	return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
}

fn left_on(a trnsfrm2d.Position, b trnsfrm2d.Position, c trnsfrm2d.Position) bool {
	return area(a, b, c) >= 0
}

fn right(a trnsfrm2d.Position, b trnsfrm2d.Position, c trnsfrm2d.Position) bool {
	return area(a, b, c) < 0
}

pub fn decompose(polygon []trnsfrm2d.Position) [][]trnsfrm2d.Position {
	mut convex_polygons := [][]trnsfrm2d.Position{}

	vertices_count := polygon.len

	mut reflex_vertices := []trnsfrm2d.Position{}

	for vertex_index in 0 .. vertices_count {
		previous_vertex_index := if vertex_index == 0 {
			vertices_count - 1
		} else {
			vertex_index - 1
		}

		prev_vertex := polygon[previous_vertex_index]
		vertex := polygon[vertex_index]
		next_vertex := polygon[(vertex_index + 1) % vertices_count]

		if is_reflect(vertex, next_vertex, prev_vertex) {
			reflex_vertices << vertex
		}
	}

	mut upper_part := []trnsfrm2d.Position{}
	mut lower_part := []trnsfrm2d.Position{}

	mut min_left := 0.0
	mut min_bottom := 0.0
	mut min_i := ?int(none)

	for reflex_vertex in reflex_vertices {
		reflex_i := polygon.index(reflex_vertex)

		for vertex_index in 1 .. vertices_count {
			next_vertex := polygon[(reflex_i + vertex_index) % vertices_count]

			if next_vertex in reflex_vertices {
				continue
			}

			previous_vertex_index := if reflex_i == 0 {
				vertices_count - 1
			} else {
				reflex_i - 1
			}

			prev_vertex := polygon[previous_vertex_index]

			if left_on(reflex_vertex, prev_vertex, next_vertex)
				&& right(reflex_vertex, polygon[(reflex_i + 1) % vertices_count], next_vertex) {
				if min_i == none || (next_vertex.y < min_bottom
					|| (next_vertex.y == min_bottom && next_vertex.x > min_left)) {
					min_left = next_vertex.x
					min_bottom = next_vertex.y
					min_i = (reflex_i + vertex_index) % vertices_count

					min_i_val := min_i or { 0 }

					upper_part = if reflex_i < min_i_val {
						polygon[reflex_i..min_i_val + 1]
					} else {
						mut combined_part := []trnsfrm2d.Position{}
						combined_part << polygon[reflex_i..]
						combined_part << polygon[..min_i_val + 1]

						combined_part
					}

					lower_part = if min_i_val < reflex_i {
						polygon[min_i_val..reflex_i + 1]
					} else {
						mut combined_part := []trnsfrm2d.Position{}
						combined_part << polygon[min_i_val..]
						combined_part << polygon[..reflex_i + 1]

						combined_part
					}
				}
			}
		}
	}

	if min_i == none {
		convex_polygons << polygon
		return convex_polygons
	}

	convex_polygons << decompose(upper_part)
	convex_polygons << decompose(lower_part)

	return convex_polygons
}

fn cross_positions(first_position trnsfrm2d.Position, second_position trnsfrm2d.Position) f64 {
	return cross(first_position.Vector, second_position.Vector)
}

fn cross(first_vector trnsfrm2d.Vector, second_vector trnsfrm2d.Vector) f64 {
	return first_vector.x * second_vector.y - first_vector.y * second_vector.x
}
