module pcoll2d

import artemkakun.trnsfrm2d
import math
import arrays

// decompose returns a list of convex polygons that are the result of decomposing the given polygon into convex polygons.
// If the given polygon is convex, then the result will be a list with the original polygon.
// ATTENTION! This method works only with counter-clockwise polygons.
// Bayazit algorithm is used to decompose the polygon.
// The algorithm is described here: https://mpen.ca/406/bayazit
pub fn decompose(polygon []trnsfrm2d.Position) [][]trnsfrm2d.Position {
	if polygon.len < 3 {
		return [polygon]
	}

	for vertex_id in 0 .. polygon.len {
		if is_reflex_vertex(polygon, vertex_id) {
			lower_poly, upper_poly := slice_polygon(polygon, vertex_id)

			if lower_poly.len < upper_poly.len {
				return arrays.concat(decompose(lower_poly), ...decompose(upper_poly))
			} else {
				return arrays.concat(decompose(upper_poly), ...decompose(lower_poly))
			}
		}
	}

	return [polygon]
}

fn is_reflex_vertex(polygon []trnsfrm2d.Position, vertex_id int) bool {
	return is_right(get_previous_vertex(polygon, vertex_id), get_vertex_at(polygon, vertex_id),
		get_next_vertex(polygon, vertex_id))
}

fn is_right(vertex_a trnsfrm2d.Position, vertex_b trnsfrm2d.Position, vertex_c trnsfrm2d.Position) bool {
	return calculate_triangle_area(vertex_a, vertex_b, vertex_c) < 0
}

fn is_left(vertex_a trnsfrm2d.Position, vertex_b trnsfrm2d.Position, vertex_c trnsfrm2d.Position) bool {
	return calculate_triangle_area(vertex_a, vertex_b, vertex_c) > 0
}

fn is_left_or_on(vertex_a trnsfrm2d.Position, vertex_b trnsfrm2d.Position, vertex_c trnsfrm2d.Position) bool {
	return calculate_triangle_area(vertex_a, vertex_b, vertex_c) >= 0
}

fn is_right_or_on(vertex_a trnsfrm2d.Position, vertex_b trnsfrm2d.Position, vertex_c trnsfrm2d.Position) bool {
	return calculate_triangle_area(vertex_a, vertex_b, vertex_c) <= 0
}

fn calculate_triangle_area(vertex_a trnsfrm2d.Position, vertex_b trnsfrm2d.Position, vertex_c trnsfrm2d.Position) f64 {
	return (vertex_b.x - vertex_a.x) * (vertex_c.y - vertex_a.y) - (vertex_b.y - vertex_a.y) * (vertex_c.x - vertex_a.x)
}

fn get_previous_vertex(polygon []trnsfrm2d.Position, vertex_id int) trnsfrm2d.Position {
	if vertex_id == 0 {
		return polygon.last()
	}

	return get_vertex_at(polygon, vertex_id - 1)
}

fn get_next_vertex(polygon []trnsfrm2d.Position, vertex_id int) trnsfrm2d.Position {
	return get_vertex_at(polygon, vertex_id + 1)
}

fn get_vertex_at(polygon []trnsfrm2d.Position, vertex_id int) trnsfrm2d.Position {
	return polygon[vertex_id % polygon.len]
}

fn slice_polygon(polygon []trnsfrm2d.Position, vertex_id int) ([]trnsfrm2d.Position, []trnsfrm2d.Position) {
	lower_intersection_point, lower_intersection_point_id := calculate_lower_intersection_point_with_id(polygon,
		vertex_id)

	upper_intersection_point, mut upper_intersection_point_id := calculate_upper_intersection_point_with_id(polygon,
		vertex_id)

	if lower_intersection_point_id == (upper_intersection_point_id + 1) % polygon.len {
		return slice_polygon_by_steiner_point(lower_intersection_point, upper_intersection_point,
			upper_intersection_point_id, lower_intersection_point_id, vertex_id, polygon)
	} else {
		closest_vertex_id := find_closest_vertex_id(polygon, lower_intersection_point_id,
			upper_intersection_point_id, vertex_id)

		return slice_polygon_by_closest_vertex(vertex_id, polygon, closest_vertex_id)
	}
}

fn calculate_lower_intersection_point_with_id(polygon []trnsfrm2d.Position, global_vertex_id int) (trnsfrm2d.Position, int) {
	mut lower_intersection_point := trnsfrm2d.Position{}
	mut lower_intersection_point_id := 0

	previous_global_vertex := get_previous_vertex(polygon, global_vertex_id)
	current_global_vertex := get_vertex_at(polygon, global_vertex_id)
	next_global_vertex := get_next_vertex(polygon, global_vertex_id)

	mut smallest_distance := math.inf(1)

	for vertex_id in 0 .. polygon.len {
		previous_vertex := get_previous_vertex(polygon, vertex_id)
		current_vertex := get_vertex_at(polygon, vertex_id)

		is_from_left := is_left(previous_global_vertex, current_global_vertex, current_vertex)

		if_from_right_or_on := is_right_or_on(previous_global_vertex, current_global_vertex,
			previous_vertex)

		if is_from_left && if_from_right_or_on {
			intersection_point := calculate_intersection_point(previous_global_vertex,
				current_global_vertex, current_vertex, previous_vertex)

			if is_right(next_global_vertex, current_global_vertex, intersection_point) {
				distance_between_current_and_intersection_vertices := trnsfrm2d.calculate_distance_between_positions(current_vertex,
					intersection_point)

				if distance_between_current_and_intersection_vertices < smallest_distance {
					smallest_distance = distance_between_current_and_intersection_vertices
					lower_intersection_point = intersection_point
					lower_intersection_point_id = vertex_id
				}
			}
		}
	}

	return lower_intersection_point, lower_intersection_point_id
}

fn calculate_upper_intersection_point_with_id(polygon []trnsfrm2d.Position, global_vertex_id int) (trnsfrm2d.Position, int) {
	mut upper_intersection_point := trnsfrm2d.Position{}
	mut upper_intersection_point_id := 0

	previous_global_vertex := get_previous_vertex(polygon, global_vertex_id)
	current_global_vertex := get_vertex_at(polygon, global_vertex_id)
	next_global_vertex := get_next_vertex(polygon, global_vertex_id)

	mut smallest_distance := math.inf(1)

	for vertex_id in 0 .. polygon.len {
		current_vertex := get_vertex_at(polygon, vertex_id)
		next_vertex := get_next_vertex(polygon, vertex_id)

		is_from_left := is_left(next_global_vertex, current_global_vertex, next_vertex)

		if_from_right_or_on := is_right_or_on(next_global_vertex, previous_global_vertex,
			current_vertex)

		if is_from_left && if_from_right_or_on {
			intersection_point := calculate_intersection_point(next_global_vertex, current_global_vertex,
				current_vertex, next_vertex)

			if is_left(previous_global_vertex, current_global_vertex, intersection_point) {
				distance_between_current_and_intersection_vertices := trnsfrm2d.calculate_distance_between_positions(current_vertex,
					intersection_point)

				if distance_between_current_and_intersection_vertices < smallest_distance {
					smallest_distance = distance_between_current_and_intersection_vertices
					upper_intersection_point = intersection_point
					upper_intersection_point_id = vertex_id
				}
			}
		}
	}

	return upper_intersection_point, upper_intersection_point_id
}

fn calculate_intersection_point(first_line_start_point trnsfrm2d.Position, first_line_end_point trnsfrm2d.Position, second_line_start_point trnsfrm2d.Position, second_line_end_point trnsfrm2d.Position) trnsfrm2d.Position {
	first_line_determinant := calculate_line_determinant(first_line_start_point, first_line_end_point)
	second_line_determinant := calculate_line_determinant(second_line_start_point, second_line_end_point)

	first_line_x_difference := first_line_start_point.x - first_line_end_point.x
	first_line_y_difference := first_line_start_point.y - first_line_end_point.y
	second_line_x_difference := second_line_start_point.x - second_line_end_point.x
	second_line_y_difference := second_line_start_point.y - second_line_end_point.y

	denominator := first_line_x_difference * second_line_y_difference - first_line_y_difference * second_line_x_difference

	if denominator.eq_epsilon(0) {
		return trnsfrm2d.Position{}
	} else {
		return trnsfrm2d.Position{
			x: calculate_intersection_point_coordinate(first_line_determinant, second_line_x_difference,
				first_line_x_difference, second_line_determinant, denominator)
			y: calculate_intersection_point_coordinate(first_line_determinant, second_line_y_difference,
				first_line_y_difference, second_line_determinant, denominator)
		}
	}
}

fn calculate_line_determinant(start_point trnsfrm2d.Position, end_point trnsfrm2d.Position) f64 {
	return start_point.x * end_point.y - start_point.y * end_point.x
}

fn calculate_intersection_point_coordinate(first_line_determinant f64, second_line_coordinate_difference f64, first_line_coordinate_difference f64, second_line_determinant f64, denominator f64) f64 {
	return (first_line_determinant * second_line_coordinate_difference - first_line_coordinate_difference * second_line_determinant) / denominator
}

fn slice_polygon_by_steiner_point(lower_intersection_point trnsfrm2d.Position, upper_intersection_point trnsfrm2d.Position, upper_intersection_point_id int, lower_intersection_point_id int, vertex_id int, polygon []trnsfrm2d.Position) ([]trnsfrm2d.Position, []trnsfrm2d.Position) {
	mut upper_poly := []trnsfrm2d.Position{}
	mut lower_poly := []trnsfrm2d.Position{}

	steiner_point := trnsfrm2d.Position{
		x: (lower_intersection_point.x + upper_intersection_point.x) / 2
		y: (lower_intersection_point.y + upper_intersection_point.y) / 2
	}

	if vertex_id < upper_intersection_point_id {
		lower_poly << polygon[vertex_id..upper_intersection_point_id + 1]
		lower_poly << steiner_point
		upper_poly << steiner_point

		if lower_intersection_point_id != 0 {
			upper_poly << polygon[lower_intersection_point_id..polygon.len]
		}

		upper_poly << polygon[0..vertex_id + 1]
	} else {
		if vertex_id != 0 {
			lower_poly << polygon[0..vertex_id + 1]
		}

		lower_poly << polygon[0..upper_intersection_point_id + 1]
		lower_poly << steiner_point
		upper_poly << steiner_point
		upper_poly << polygon[lower_intersection_point_id..vertex_id + 1]
	}

	return lower_poly, upper_poly
}

fn find_closest_vertex_id(polygon []trnsfrm2d.Position, lower_intersection_point_id int, upper_intersection_point_id int, global_vertex_id int) int {
	upper_point_id_shift := if lower_intersection_point_id > upper_intersection_point_id {
		polygon.len
	} else {
		0
	}

	mut smallest_distance := math.inf(1)
	mut closest_vertex_id := 0

	previous_global_vertex := get_previous_vertex(polygon, global_vertex_id)
	current_global_vertex := get_vertex_at(polygon, global_vertex_id)
	next_global_vertex := get_next_vertex(polygon, global_vertex_id)

	up_search_vertex_id := upper_intersection_point_id + upper_point_id_shift + 1

	for vertex_id in lower_intersection_point_id .. up_search_vertex_id {
		is_from_left_or_on := is_left_or_on(previous_global_vertex, current_global_vertex,
			get_vertex_at(polygon, vertex_id))

		is_from_right_or_on := is_right_or_on(next_global_vertex, current_global_vertex,
			get_vertex_at(polygon, vertex_id))

		if is_from_left_or_on && is_from_right_or_on {
			distance := trnsfrm2d.calculate_distance_between_positions(current_global_vertex,
				get_vertex_at(polygon, vertex_id))

			if distance < smallest_distance {
				smallest_distance = distance
				closest_vertex_id = vertex_id % polygon.len
			}
		}
	}

	return closest_vertex_id
}

fn slice_polygon_by_closest_vertex(vertex_id int, polygon []trnsfrm2d.Position, closest_vertex_id int) ([]trnsfrm2d.Position, []trnsfrm2d.Position) {
	mut upper_poly := []trnsfrm2d.Position{}
	mut lower_poly := []trnsfrm2d.Position{}

	if vertex_id < closest_vertex_id {
		lower_poly << polygon[vertex_id..closest_vertex_id + 1]

		if closest_vertex_id != 0 {
			upper_poly << polygon[closest_vertex_id..polygon.len]
		}

		upper_poly << polygon[0..vertex_id + 1]
	} else {
		if vertex_id != 0 {
			lower_poly << polygon[vertex_id..polygon.len]
		}

		lower_poly << polygon[0..closest_vertex_id + 1]
		upper_poly << polygon[closest_vertex_id..vertex_id + 1]
	}

	return lower_poly, upper_poly
}
