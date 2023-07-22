module pcoll2d

import artemkakun.trnsfrm2d
import arrays
import math

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

// def lineInt(l1, l2, precision=0):
//    """Compute the intersection between two lines.
//
//    Keyword arguments:
//    l1 -- first line
//    l2 -- second line
//    precision -- precision to check if lines are parallel (default 0)
//
//    Returns:
//    The intersection point
//    """
//    i = [0, 0] # point
//    a1 = l1[1][1] - l1[0][1]
//    b1 = l1[0][0] - l1[1][0]
//    c1 = a1 * l1[0][0] + b1 * l1[0][1]
//    a2 = l2[1][1] - l2[0][1]
//    b2 = l2[0][0] - l2[1][0]
//    c2 = a2 * l2[0][0] + b2 * l2[0][1]
//    det = a1 * b2 - a2 * b1
//    if not scalar_eq(det, 0, precision): # lines are not parallel
//        i[0] = (b2 * c1 - b1 * c2) / det
//        i[1] = (a1 * c2 - a2 * c1) / det
//    return i
//

fn find_line_intersection_point(first_line_points [2]trnsfrm2d.Position, second_line_points [2]trnsfrm2d.Position) trnsfrm2d.Position {
	a1 := first_line_points[1].y - first_line_points[0].y
	b1 := first_line_points[0].x - first_line_points[1].x
	c1 := a1 * first_line_points[0].x + b1 * first_line_points[0].y

	a2 := second_line_points[1].y - second_line_points[0].y
	b2 := second_line_points[0].x - second_line_points[1].x
	c2 := a2 * second_line_points[0].x + b2 * second_line_points[0].y

	det := a1 * b2 - a2 * b1

	if det.eq_epsilon(0) {
		return trnsfrm2d.Position{
			x: 0
			y: 0
		}
	} else {
		return trnsfrm2d.Position{
			x: (b2 * c1 - b1 * c2) / det
			y: (a1 * c2 - a2 * c1) / det
		}
	}
}

// def triangleArea(a, b, c):
//    """Calculates the area of a triangle spanned by three points.
//    Note that the area will be negative if the points are not given in counter-clockwise order.
//
//    Keyword arguments:
//    a -- First point
//    b -- Second point
//    c -- Third point
//
//    Returns:
//    Area of triangle
//    """
//    return ((b[0] - a[0])*(c[1] - a[1]))-((c[0] - a[0])*(b[1] - a[1]))
//

fn calculate_triangle_area(vertex_a trnsfrm2d.Position, vertex_b trnsfrm2d.Position, vertex_c trnsfrm2d.Position) f64 {
	return (vertex_b.x - vertex_a.x) * (vertex_c.y - vertex_a.y) - (vertex_b.y - vertex_a.y) * (vertex_c.x - vertex_a.x)
}

fn is_left_or_on(vertex_a trnsfrm2d.Position, vertex_b trnsfrm2d.Position, vertex_c trnsfrm2d.Position) bool {
	return calculate_triangle_area(vertex_a, vertex_b, vertex_c) >= 0
}

fn is_right(vertex_a trnsfrm2d.Position, vertex_b trnsfrm2d.Position, vertex_c trnsfrm2d.Position) bool {
	return calculate_triangle_area(vertex_a, vertex_b, vertex_c) < 0
}

fn is_right_or_on(vertex_a trnsfrm2d.Position, vertex_b trnsfrm2d.Position, vertex_c trnsfrm2d.Position) bool {
	return calculate_triangle_area(vertex_a, vertex_b, vertex_c) <= 0
}

// def sqdist(a, b):
//    dx = b[0] - a[0]
//    dy = b[1] - a[1]
//    return dx * dx + dy * dy
//

fn calculate_sqdist(vertex_a trnsfrm2d.Position, vertex_b trnsfrm2d.Position) f64 {
	dx := vertex_b.x - vertex_a.x
	dy := vertex_b.y - vertex_a.y
	return dx * dx + dy * dy
}

// def polygonAt(polygon, i):
//    """Gets a vertex at position i on the polygon.
//    It does not matter if i is out of bounds.
//
//    Keyword arguments:
//    polygon -- The polygon
//    i -- Position desired on the polygon
//
//    Returns:
//    Vertex at position i
//    """
//    s = len(polygon)
//    return polygon[i % s]
//

fn get_vertex_at(polygon []trnsfrm2d.Position, i int) trnsfrm2d.Position {
	s := polygon.len
	return polygon[i % s]
}

// def polygonIsReflex(polygon, i):
//    """Checks if a point in the polygon is a reflex point.
//
//    Keyword arguments:
//    polygon -- The polygon
//    i -- index of point to check
//
//    Returns:
//    True is point is a reflex point
//
//    """
//    return isRight(polygonAt(polygon, i - 1), polygonAt(polygon, i), polygonAt(polygon, i + 1))
//

fn is_reflex(polygon []trnsfrm2d.Position, i int) bool {
	return is_right(get_previous_vertex(polygon, i - 1), get_vertex_at(polygon, i), get_vertex_at(polygon,
		i + 1))
}

// def polygonCanSee(polygon, a, b):
//    """Checks if two vertices in the polygon can see each other.
//
//    Keyword arguments:
//    polygon -- The polygon
//    a -- Vertex 1
//    b -- Vertex 2
//
//    Returns:
//    True if vertices can see each other
//
//    """
//
//    l1 = [None]*2
//    l2 = [None]*2
//
//    if isLeftOn(polygonAt(polygon, a + 1), polygonAt(polygon, a), polygonAt(polygon, b)) and isRightOn(polygonAt(polygon, a - 1), polygonAt(polygon, a), polygonAt(polygon, b)):
//        return False
//
//    dist = sqdist(polygonAt(polygon, a), polygonAt(polygon, b))
//    for i in xrange(0, len(polygon)): # for each edge
//        if (i + 1) % len(polygon) == a or i == a: # ignore incident edges
//            continue
//
//        if isLeftOn(polygonAt(polygon, a), polygonAt(polygon, b), polygonAt(polygon, i + 1)) and isRightOn(polygonAt(polygon, a), polygonAt(polygon, b), polygonAt(polygon, i)): # if diag intersects an edge
//            l1[0] = polygonAt(polygon, a)
//            l1[1] = polygonAt(polygon, b)
//            l2[0] = polygonAt(polygon, i)
//            l2[1] = polygonAt(polygon, i + 1)
//            p = lineInt(l1, l2)
//            if sqdist(polygonAt(polygon, a), p) < dist: # if edge is blocking visibility to b
//                return False
//
//    return True

fn can_see(polygon []trnsfrm2d.Position, a int, b int) bool {
	mut l1 := [2]trnsfrm2d.Position{}
	mut l2 := [2]trnsfrm2d.Position{}

	if is_left_or_on(get_vertex_at(polygon, a + 1), get_vertex_at(polygon, a), get_vertex_at(polygon, b))
		&& is_right_or_on(get_vertex_at(polygon, a - 1), get_vertex_at(polygon, a), get_vertex_at(polygon, b)) {
		return false
	}

	dist := calculate_sqdist(get_vertex_at(polygon, a), get_vertex_at(polygon, b))

	for i in 0 .. polygon.len { // for each edge
		if (i + 1) % polygon.len == a || i == a { // ignore incident edges
			continue
		}

		if is_left_or_on(get_vertex_at(polygon, a), get_vertex_at(polygon, b), get_vertex_at(polygon, i + 1))
			&& is_right_or_on(get_vertex_at(polygon, a), get_vertex_at(polygon, b), get_vertex_at(polygon, i)) { // if diag intersects an edge
			l1[0] = get_vertex_at(polygon, a)
			l1[1] = get_vertex_at(polygon, b)
			l2[0] = get_vertex_at(polygon, i)
			l2[1] = get_vertex_at(polygon, i + 1)
			p := find_line_intersection_point(l1, l2)
			if calculate_sqdist(get_vertex_at(polygon, a), p) < dist { // if edge is blocking visibility to b
				return false
			}
		}
	}

	return true
}

// def polygonCopy(polygon, i, j, targetPoly=None):
//    """Copies the polygon from vertex i to vertex j to targetPoly.
//
//    Keyword arguments:
//    polygon -- The source polygon
//    i -- start vertex
//    j -- end vertex (inclusive)
//    targetPoly -- Optional target polygon
//
//    Returns:
//    The resulting copy.
//
//    """
//    p = targetPoly or []
//    polygonClear(p)
//    if i < j:
//        # Insert all vertices from i to j
//        for k in xrange(i, j+1):
//            p.append(polygon[k])
//
//    else:
//        # Insert vertices 0 to j
//        for k in xrange(0, j+1):
//            p.append(polygon[k])
//
//        # Insert vertices i to end
//        for k in xrange(i, len(polygon)):
//            p.append(polygon[k])
//
//    return p

fn copy_polygon(polygon []trnsfrm2d.Position, i int, j int) []trnsfrm2d.Position {
	mut p := []trnsfrm2d.Position{}

	if i < j {
		// Insert all vertices from i to j
		for k in i .. j + 1 {
			p << polygon[k]
		}
	} else {
		// Insert vertices 0 to j
		for k in 0 .. j + 1 {
			p << polygon[k]
		}

		// Insert vertices i to end
		for k in i .. polygon.len {
			p << polygon[k]
		}
	}

	return p
}

// def polygonGetCutEdges(polygon):
//    """Decomposes the polygon into convex pieces.
//    Note that this algorithm has complexity O(N^4) and will be very slow for polygons with many vertices.
//
//    Keyword arguments:
//    polygon -- The polygon
//
//    Returns:
//    A list of edges [[p1,p2],[p2,p3],...] that cut the polygon.
//
//    """
//    mins = []
//    tmp1 = []
//    tmp2 = []
//    tmpPoly = []
//    nDiags = float('inf')
//
//    for i in xrange(0, len(polygon)):
//        if polygonIsReflex(polygon, i):
//            for j in xrange(0, len(polygon)):
//                if polygonCanSee(polygon, i, j):
//                    tmp1 = polygonGetCutEdges(polygonCopy(polygon, i, j, tmpPoly))
//                    tmp2 = polygonGetCutEdges(polygonCopy(polygon, j, i, tmpPoly))
//
//                    for k in xrange(0, len(tmp2)):
//                        tmp1.append(tmp2[k])
//
//                    if len(tmp1) < nDiags:
//                        mins = tmp1
//                        nDiags = len(tmp1)
//                        mins.append([polygonAt(polygon, i), polygonAt(polygon, j)])
//
//    return mins

fn get_cut_edges(polygon []trnsfrm2d.Position) [][]trnsfrm2d.Position {
	mut mins := [][]trnsfrm2d.Position{}
	mut tmp1 := [][]trnsfrm2d.Position{}
	mut tmp2 := [][]trnsfrm2d.Position{}
	mut n_diags := math.inf(1)

	for i in 0 .. polygon.len {
		if is_reflex(polygon, i) {
			for j in 0 .. polygon.len {
				if can_see(polygon, i, j) {
					tmp1 = get_cut_edges(copy_polygon(polygon, i, j))
					tmp2 = get_cut_edges(copy_polygon(polygon, j, i))

					for k in 0 .. tmp2.len {
						tmp1 << tmp2[k]
					}

					if tmp1.len < n_diags {
						mins = tmp1.clone()
						n_diags = tmp1.len
						mins << [get_vertex_at(polygon, i), get_vertex_at(polygon, j)]
					}
				}
			}
		}
	}

	return mins
}

// def polygonSlice(polygon, cutEdges):
//    """Slices the polygon given one or more cut edges. If given one, this function will return two polygons (false on failure). If many, an array of polygons.
//
//    Keyword arguments:
//    polygon -- The polygon
//    cutEdges -- A list of edges to cut on, as returned by getCutEdges()
//
//    Returns:
//    An array of polygon objects.
//
//    """
//    if len(cutEdges) == 0:
//        return [polygon]
//
//    if isinstance(cutEdges, list) and len(cutEdges) != 0 and isinstance(cutEdges[0], list) and len(cutEdges[0]) == 2 and isinstance(cutEdges[0][0], list):
//
//        polys = [polygon]
//
//        for i in xrange(0, len(cutEdges)):
//            cutEdge = cutEdges[i]
//            # Cut all polys
//            for j in xrange(0, len(polys)):
//                poly = polys[j]
//                result = polygonSlice(poly, cutEdge)
//                if result:
//                    # Found poly! Cut and quit
//                    del polys[j:j+1]
//                    polys.extend((result[0], result[1]))
//                    break
//
//        return polys
//    else:
//
//        # Was given one edge
//        cutEdge = cutEdges
//        i = polygon.index(cutEdge[0])
//        j = polygon.index(cutEdge[1])
//
//        if i != -1 and j != -1:
//            return [polygonCopy(polygon, i, j),
//                    polygonCopy(polygon, j, i)]
//        else:
//            return False
//

fn slice_polygon(polygon []trnsfrm2d.Position, cut_edges [][]trnsfrm2d.Position) [][]trnsfrm2d.Position {
	if cut_edges.len == 0 {
		return [polygon]
	}

	mut polys := [polygon]

	for i in 0 .. cut_edges.len {
		mut cut_edge := cut_edges[i]
		// Cut all polys
		for j in 0 .. polys.len {
			mut poly := polys[j]
			mut result := cut_polygon_by_edge(poly, cut_edge)
			if result != none {
				for k in j .. j + 1 {
					polys.delete(k)
				}

				polys << result or { break }[0]
				polys << result or { break }[1]
				break
			}
		}
	}

	return polys
}

fn cut_polygon_by_edge(polygon []trnsfrm2d.Position, cut_edge []trnsfrm2d.Position) ?[][]trnsfrm2d.Position {
	mut i := polygon.index(cut_edge[0])
	mut j := polygon.index(cut_edge[1])

	if i != -1 && j != -1 {
		return [copy_polygon(polygon, i, j), copy_polygon(polygon, j, i)]
	} else {
		return none
	}
}

// def polygonDecomp(polygon):
//    """Decomposes the polygon into one or more convex sub-polygons.
//
//    Keyword arguments:
//    polygon -- The polygon
//
//    Returns:
//    An array or polygon objects.
//
//    """
//    edges = polygonGetCutEdges(polygon)
//    if len(edges) > 0:
//        return polygonSlice(polygon, edges)
//    else:
//        return [polygon]
//

pub fn decomp_polygon(polygon []trnsfrm2d.Position) [][]trnsfrm2d.Position {
	mut edges := get_cut_edges(polygon)

	if edges.len > 0 {
		return slice_polygon(polygon, edges)
	} else {
		return [polygon]
	}
}
