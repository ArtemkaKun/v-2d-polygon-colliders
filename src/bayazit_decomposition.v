module pcoll2d

import artemkakun.trnsfrm2d
import arrays

// decompose returns a list of convex polygons that are the result of decomposing the given polygon into convex polygons.
// If the given polygon is convex, then the result will be a list with the original polygon.
// Bayazit algorithm is used to decompose the polygon.
// The algorithm is described here: https://mpen.ca/406/bayazit
pub fn decompose(polygon []trnsfrm2d.Position) [][]trnsfrm2d.Position {
	reflex_vertices_ids := get_reflect_vertices_ids(polygon)

	mut min_vertex_id := ?int(none)
	mut min_vertex := trnsfrm2d.Position{}

	mut polygon_parts := [2][]trnsfrm2d.Position{}

	vertices_count := polygon.len

	for reflex_vertex_id in reflex_vertices_ids {
		reflex_vertex := polygon[reflex_vertex_id]

		for vertex_index in 1 .. vertices_count {
			next_vertex_id := (reflex_vertex_id + vertex_index) % vertices_count

			if next_vertex_id in reflex_vertices_ids {
				continue
			}

			next_vertex := polygon[next_vertex_id]
			prev_vertex := get_previous_vertex(polygon, reflex_vertex_id)

			is_reflex_vertex_left_or_on := is_left_or_on(reflex_vertex, prev_vertex, next_vertex)
			is_reflex_vertex_right := is_right(reflex_vertex, get_next_vertex(polygon,
				reflex_vertex_id), next_vertex)

			if is_reflex_vertex_left_or_on && is_reflex_vertex_right {
				is_next_vertex_under_or_right_to_min := is_vertex_under_or_right(next_vertex,
					min_vertex)

				if min_vertex_id == none || is_next_vertex_under_or_right_to_min {
					min_vertex_id = next_vertex_id
					min_vertex = next_vertex

					min_vertex_id_value := min_vertex_id or { 0 } // NOTE: or block is never executed

					polygon_parts = [
						calculate_cut_part(polygon, reflex_vertex_id, min_vertex_id_value),
						calculate_cut_part(polygon, min_vertex_id_value, reflex_vertex_id),
					]!
				}
			}
		}
	}

	if min_vertex_id == none {
		return [polygon]
	}

	return arrays.concat(decompose(polygon_parts[0]), ...decompose(polygon_parts[1]))
}

fn get_reflect_vertices_ids(polygon []trnsfrm2d.Position) []int {
	mut reflex_vertices_ids := []int{}

	for vertex_index in 0 .. polygon.len {
		prev_vertex := get_previous_vertex(polygon, vertex_index)
		vertex := polygon[vertex_index]
		next_vertex := get_next_vertex(polygon, vertex_index)

		if is_reflect(prev_vertex, vertex, next_vertex) {
			reflex_vertices_ids << vertex_index
		}
	}

	return reflex_vertices_ids
}

fn get_previous_vertex(polygon []trnsfrm2d.Position, vertex_index int) trnsfrm2d.Position {
	if vertex_index == 0 {
		return polygon.last()
	}

	return polygon[vertex_index - 1]
}

fn get_next_vertex(polygon []trnsfrm2d.Position, vertex_index int) trnsfrm2d.Position {
	return polygon[(vertex_index + 1) % polygon.len]
}

fn is_reflect(prev_vertex trnsfrm2d.Position, vertex trnsfrm2d.Position, next_vertex trnsfrm2d.Position) bool {
	return (next_vertex.y - vertex.y) * (prev_vertex.x - vertex.x) < (next_vertex.x - vertex.x) * (prev_vertex.y - vertex.y)
}

fn is_left_or_on(vertex_a trnsfrm2d.Position, vertex_b trnsfrm2d.Position, vertex_c trnsfrm2d.Position) bool {
	return calculate_polygon_area(vertex_a, vertex_b, vertex_c) >= 0
}

fn is_right(vertex_a trnsfrm2d.Position, vertex_b trnsfrm2d.Position, vertex_c trnsfrm2d.Position) bool {
	return calculate_polygon_area(vertex_a, vertex_b, vertex_c) < 0
}

fn calculate_polygon_area(vertex_a trnsfrm2d.Position, vertex_b trnsfrm2d.Position, vertex_c trnsfrm2d.Position) f64 {
	return (vertex_b.x - vertex_a.x) * (vertex_c.y - vertex_a.y) - (vertex_b.y - vertex_a.y) * (vertex_c.x - vertex_a.x)
}

fn is_vertex_under_or_right(vertex trnsfrm2d.Position, another_vertex trnsfrm2d.Position) bool {
	is_vertex_right := vertex.y == another_vertex.y && vertex.x > another_vertex.x

	return vertex.y < another_vertex.y || is_vertex_right
}

fn calculate_cut_part(polygon []trnsfrm2d.Position, start_vertex_id int, end_vertex_id int) []trnsfrm2d.Position {
	incremented_end_vertex_id := end_vertex_id + 1

	if start_vertex_id < end_vertex_id {
		return polygon[start_vertex_id..incremented_end_vertex_id]
	} else {
		return arrays.concat(polygon[start_vertex_id..], ...polygon[..incremented_end_vertex_id])
	}
}
