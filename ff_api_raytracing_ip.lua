function prepare()
	--	Threshold for correct collision detection
	SKIN = 1e-10
	--	Max reflection/refraction iterations
	MAX_ITERATIONS = 4
	--	Min value of material reflection
	MIN_REFLECTION = 0

	--	Spheres
	NUMBER_OF_SPHERES = 1
	spheres = {
		{center = {0;  1.5 - 2 * get_slider_input(SPHERE1_HEIGHT);  -0.5}; radius = 1.8; color = {1; 1; 1; 0}; refl = 0.25; ior = 1.52; fresnel_refl = false; normal = {0; 0; -1}; tangent1 = {0; 0; 0}; tangent2 = {0; 0; 0};};
	-- {center = {-0.8; 4.2 - 2 * get_slider_input(SPHERE2_HEIGHT); 4.5}; radius = 0.8; color = {1; 1; 1; 0}; refl = 1; ior = 1.52; fresnel_refl = true; normal = {1; 0; 0}; tangent1 = {0; 0; 0}; tangent2 = {0; 0; 0};};
	}

	local sphere_i = 1
	while (sphere_i <= NUMBER_OF_SPHERES) do
		spheres[sphere_i].tangent1, spheres[sphere_i].tangent2 = get_tangent_vectors(spheres[sphere_i].normal)
		sphere_i = sphere_i + 1
	end 

	--	Planes
	NUMBER_OF_PLANES = 6
	planes = { 
		{point = {-8; 0; 0}; normal = {1; 0; 0}; tangent1 = {0; 0; 0}; tangent2 = {0; 0; 0}; color = {1; 0; 0; 1}; refl = 0; fresnel_refl = false};
		{point = {8; 0; 0}; normal = {-1; 0; 0}; tangent1 = {0; 0; 0}; tangent2 = {0; 0; 0}; color = {0; 1; 0; 1}; refl = 0; fresnel_refl = false};
		{point = {0; 8; 0}; normal = {0; -1; 0}; tangent1 = {0; 0; 0}; tangent2 = {0; 0; 0}; color = {1; 1; 1; 1}; refl = 0; fresnel_refl = false};
		{point = {0; -8; 0}; normal = {0; 1; 0}; tangent1 = {0; 0; 0}; tangent2 = {0; 0; 0}; color = {1; 1; 1; 1}; refl = 0; fresnel_refl = false};
		{point = {0; 0; 8}; normal = {0; 0; -1}; tangent1 = {0; 0; 0}; tangent2 = {0; 0; 0}; color = {1; 1; 1; 1}; refl = 0; fresnel_refl = false};
		{point = {0; 0; -8}; normal = {0; 0; 1}; tangent1 = {0; 0; 0}; tangent2 = {0; 0; 0}; color = {0; 0; 0; 1}; refl = 0; fresnel_refl = false};
	}

	local plane_ind = 1
	while (plane_ind <= NUMBER_OF_PLANES) do
		planes[plane_ind].tangent1, planes[plane_ind].tangent2 = get_tangent_vectors(planes[plane_ind].normal)
		plane_ind = plane_ind + 1
	end 

	--	Lights
	NUMBER_OF_LIGHTS = 2
	lights = {
		{position = {0, -1.6, -1}; color = {1; 1; 1}; shadow_density = 0.8};
		{position = {0, 0, 1}; color = {0.5; 0.5; 0.5}; shadow_density = 0.8}
	}
	
	--	Camera parameters
	--		Field of view
	FOV = math.pi / 4
	half_fov_tan = math.tan(FOV / 2)
	camera_pos = {0, 0, -6.5}
end;

function dot_product(vector1, vector2)
    return vector1[1] * vector2[1] + vector1[2] * vector2[2] + vector1[3] * vector2[3]
end;

function cross_product(vector1, vector2)
    return 
      {vector1[2] * vector2[3] - vector1[3] * vector2[2];
      vector1[3] * vector2[1] - vector1[1] * vector2[3];
      vector1[1] * vector2[2] - vector1[2] * vector2[1]}
end;

function get_tangent_vectors(normal)
	local up_vector = {0, -1, 0}
	if (normal[2] == 1) or (normal[2] == -1) then
		up_vector = {1, 0, 0}
	end
	local tangent1 = cross_product(normal, up_vector)
	tangent1 = get_normalized(tangent1)
	local tangent2 = get_normalized(cross_product(normal, tangent1))
	return tangent1, tangent2
end;

function get_length(vector)
	return math.sqrt(vector[1] ^ 2 + vector[2] ^ 2 + vector[3] ^ 2)
end

function get_length_sq(vector)
	return vector[1] ^ 2 + vector[2] ^ 2 + vector[3] ^ 2
end

function get_normalized(vector)
    local length = get_length(vector)
    return {vector[1] / length;  vector[2] / length; vector[3] / length}
end;

function get_reflected_ray(ray, normal)
	local d = -2 * dot_product(ray, normal)
	local result = {ray[1] + d * normal[1], ray[2] + d * normal[2], ray[3] + d * normal[3]}
	return get_normalized(result)
end;

function get_refracted_ray(ray, normal, ior1, ior2)
	local n = ior1 / ior2
	local dot = dot_product(ray, normal)
	local sine_sq = n * n * (1 - dot ^ 2)
	if (sine_sq > 1) then
		return nil
	end
	local coeff = n * dot + math.sqrt(1 - sine_sq)
	return get_normalized({
		n * ray[1] - coeff * normal[1],
		n * ray[2] - coeff * normal[2],
		n * ray[3] - coeff * normal[3]})
end;

function get_schlick_approx(n_dot_l)
	return MIN_REFLECTION + (1 - MIN_REFLECTION) * (1 - n_dot_l) ^ 5
end;

function sphere_intersection(origin, ray, center, radius)
	local to_center = {
		center[1] - origin[1];
		center[2] - origin[2];
		center[3] - origin[3];
	}
	local dot = dot_product(ray, to_center)
	local dist = radius^2 - get_length_sq(to_center) + dot^2
	if (dist < 0) then
		return -1
	else
		dist = dot - math.sqrt(dist)
		local normal = {
			dist * ray[1] - to_center[1]; 
			dist * ray[2] - to_center[2];
			dist * ray[3] - to_center[3]}
		return dist, get_normalized(normal)
	end
end;

function sphere_refraction(sphere_point, ray, normal, center, radius, ior)
	local to_center = {
		center[1] - sphere_point[1],
		center[2] - sphere_point[2],
		center[3] - sphere_point[3]}
	local refracted_ray = get_refracted_ray(ray, normal, 1, ior)
	if (refracted_ray == nil) then
		return nil
	end
	local distance_to_out =  2 * dot_product(refracted_ray, to_center) + SKIN
	local out_point = {
	sphere_point[1] + refracted_ray[1] * distance_to_out;
	sphere_point[2] + refracted_ray[2] * distance_to_out;
	sphere_point[3] + refracted_ray[3] * distance_to_out}

	local out_normal = get_normalized({
		-(out_point[1] - center[1]); 
		-(out_point[2] - center[2]);
		-(out_point[3] - center[3])})

	local out_ray = get_refracted_ray(refracted_ray, out_normal, ior, 1)
	if (out_ray == nil) then
		return nil
	end
	return out_point, out_ray
end;

function plane_indntersection(origin, ray, plane_point, normal)
	local to_plane = {
		plane_point[1] - origin[1];
		plane_point[2] - origin[2];
		plane_point[3] - origin[3]
	}
	local proj = -dot_product(ray, normal)
	if (proj <= 0) then 
		return -1
	end
	local dist = -dot_product(normal, to_plane) / proj

	if (dist < 0) then
		return -1
	else
		return dist, normal
	end
end;

function cast_ray(origin, ray, edge)
	local dist = nil
	local normal = {0; 0; 0}
	local color = {0, 0, 0, 0}
	local refl

	local refr_origin = nil
	local refr_ray = nil
	local fresnel_refl = false

	local aa_zone = 0
	local sphere_i = 1
	while sphere_i <= NUMBER_OF_SPHERES do
		local cur_dist, cur_normal = sphere_intersection(
		origin, ray, spheres[sphere_i].center, spheres[sphere_i].radius)
		if (cur_dist > 0) then
			cur_dist = cur_dist - SKIN
			if (dist == nil) or (cur_dist < dist) then
				dist = cur_dist
				normal = cur_normal
					
	if (sphere_i ~= 0) then
		local point = {
			origin[1] + dist * ray[1] - spheres[sphere_i].center[1];
			origin[2] + dist * ray[2] - spheres[sphere_i].center[2];
			origin[3] + dist * ray[3] - spheres[sphere_i].center[3]}
		local u, v = dot_product(spheres[sphere_i].tangent1, point) / 4 + 0.5, dot_product(spheres[sphere_i].tangent2, point) / 4 + 0.5
		if (sphere_i == 1) then
			color[1], color[2], color[3], color[4] = get_sample_map(u, v, ORB)
		else
				color = spheres[sphere_i].color 
		end
	end

				refl, fresnel_refl, ior = 
					spheres[sphere_i].refl, spheres[sphere_i].fresnel_refl, spheres[sphere_i].ior
				if (color[4] < 1) then
					refr_origin, refr_ray = sphere_refraction(
						{origin[1] + dist * ray[1], origin[2] + dist * ray[2], origin[3] + dist * ray[3]},
						ray, normal,
						spheres[sphere_i].center, spheres[sphere_i].radius, ior)
					aa_zone = sphere_i
				end
			end
		end
		sphere_i = sphere_i + 1
	end

	local nearest_plane = 0
	local plane_ind = 1
	while (plane_ind <= NUMBER_OF_PLANES) do
		local cur_dist, cur_normal = 
			plane_indntersection(origin, ray, planes[plane_ind].point, planes[plane_ind].normal)
		if (cur_dist > 0) then
			cur_dist = cur_dist - SKIN
		if (dist == nil) or (cur_dist < dist) then
			dist = cur_dist
			normal = cur_normal
			nearest_plane = plane_ind
			aa_zone = NUMBER_OF_SPHERES + plane_ind
		end
	end
	plane_ind = plane_ind + 1
end
 
	if (nearest_plane ~= 0) then
		local point = {
			origin[1] + dist * ray[1] - planes[nearest_plane].point[1];
			origin[2] + dist * ray[2] - planes[nearest_plane].point[2];
			origin[3] + dist * ray[3] - planes[nearest_plane].point[3]}
		local u, v = dot_product(planes[nearest_plane].tangent1, point) / 4 + 0.5, dot_product(planes[nearest_plane].tangent2, point) / 4 + 0.5
		refl, fresnel_refl = planes[nearest_plane].refl, planes[nearest_plane].fresnel_refl
		color[4] = 1
		if (nearest_plane == 1) then
			color[1], color[2], color[3] = get_sample_map(u, v, LEFT_WALL)
		elseif (nearest_plane == 2) then
			color[1], color[2], color[3] = get_sample_map(u, v, RIGHT_WALL)
		elseif (nearest_plane == 3) then
			color[1], color[2], color[3] = get_sample_map(u, v, FLOOR)
		elseif (nearest_plane == 4) then
			color[1], color[2], color[3] = get_sample_map(u, v, CEILING)
		elseif (nearest_plane == 5) then
			color[1], color[2], color[3] = get_sample_map(u, v, BACK_WALL)
		elseif (nearest_plane == 6) then
			color[1], color[2], color[3] = get_sample_map(u, v, FRONT_WALL)
		end   
	end
 
	return dist, normal, color, refl, fresnel_refl, refr_origin, refr_ray, combine_aa_zones(edge, aa_zone)
end;

function get_light_visibility(origin, to_light_ray, light_dist, edge)
	local visibility = 1
	local sphere_i = 1
	while sphere_i <= NUMBER_OF_SPHERES do
		local dist = sphere_intersection(origin, to_light_ray, 
		spheres[sphere_i].center, spheres[sphere_i].radius)
		if (dist > 0) and (dist < light_dist) then
			edge = combine_aa_zones(edge, sphere_i)
			visibility = visibility * math.min(0.5, 1.0 - spheres[sphere_i].color[4])
			if (visibility == 0) then
				return visibility, edge
			end
		end
		sphere_i = sphere_i + 1
	end

	local plane_ind = 1
	while plane_ind <= NUMBER_OF_PLANES do
		local dist = plane_indntersection(origin, to_light_ray, 
		planes[plane_ind].point, planes[plane_ind].normal)
		if (dist > 0) and (dist < light_dist) then
			edge = combine_aa_zones(edge, NUMBER_OF_SPHERES + plane_ind)
			visibility = visibility * (1.0 - planes[plane_ind].color[4])
			if (visibility == 0) then
				return visibility, edge
			end
		end
		plane_ind = plane_ind + 1
	end
	return visibility, edge
end;

function trace_ray(origin, ray, iteration, edge)
	local dist, normal, color, refl, fresnel_refl, refr_origin, refr_ray, current_edge = cast_ray(origin, ray, edge)
	if (dist == nil) then
		return 0, 0, 0, 1
	end
	local result = {0, 0, 0}
	local hit = {
		origin[1] + dist * ray[1]; 
		origin[2] + dist * ray[2]; 
		origin[3] + dist * ray[3]}

	local refl_normal = get_reflected_ray(ray, normal)
	if (fresnel_refl) then
		refl = refl * get_schlick_approx(dot_product(refl_normal, normal))
	end

	if (refl > 0) and (iteration < MAX_ITERATIONS) then
		local refl_r, refl_g, refl_b
		refl_r, refl_g, refl_b, current_edge = trace_ray(hit, refl_normal, iteration + 1, current_edge)
		result[1] = result[1] + refl * refl_r
		result[2] = result[2] + refl * refl_g
		result[3] = result[3] + refl * refl_b
	end

	if (color[4] < 1) and (iteration < MAX_ITERATIONS) and (refr_origin ~= nil) then
		local refr_r, refr_g, refr_b
		refr_r, refr_g, refr_b, current_edge = trace_ray(refr_origin, refr_ray, iteration + 1, current_edge)
		local refr_scale = (1 - refl) * (1.0 - color[4])
		result[1] = result[1] + refr_scale * refr_r
		result[2] = result[2] + refr_scale * refr_g
		result[3] = result[3] + refr_scale * refr_b
	end

	local light_i = 1
	while (light_i <= NUMBER_OF_LIGHTS) do
		local to_light = {
		lights[light_i].position[1]- hit[1]; 
		lights[light_i].position[2] - hit[2]; 
		lights[light_i].position[3] - hit[3]}
		local light_dist = get_length(to_light)
		to_light[1] = to_light[1] / light_dist
		to_light[2] = to_light[2] / light_dist
		to_light[3] = to_light[3] / light_dist

		local dot = dot_product(to_light, normal)
		local light_diff = (1 - refl) * color[4]

		local light_visibility
		light_visibility, current_edge = get_light_visibility(hit, to_light, light_dist, current_edge)
		if (dot > 0) then
			local light_color = lights[light_i].color
			local shadow = 1.0 - lights[light_i].shadow_density * (1.0 - light_visibility)
			local diff_scale = light_diff * dot * color[4] * shadow
			result[1] = result[1] + color[1] * light_color[1] * diff_scale
			result[2] = result[2] + color[2] * light_color[2] * diff_scale
			result[3] = result[3] + color[3] * light_color[3] * diff_scale
		end
		light_i = light_i + 1
	end
	return result[1], result[2], result[3], current_edge
end;

function get_sample(x, y, t)
	local ray = {(x * 2 - 1) * half_fov_tan, (y * 2 - 1) * half_fov_tan, 1}
	ray = get_normalized(ray)
	local r, g, b, edge = trace_ray(camera_pos, ray, 0, 0)
	return r, g, b, 1, edge
end;