classdef Ray < handle

  properties
    origin;
    position;
    direction;
    distancePerStep = 0.01;
    numberOfSteps = 500;
    currentIoR = 1.0;
  endproperties

  methods
    % Constructor
    function obj = Ray(origin, angle)
      % Initialize variables
      obj.origin = origin;
      obj.position = origin;
      obj.direction = [cos(angle),sin(angle)];

      % Main ray tracing program
      obj.computeRayPath();
      obj.render();
    endfunction

    % Compute ray path
    function computeRayPath(obj)

      % Get all objects in the scene
      scene = get(gca,'userdata');

      % Its tracin' time
      for step = 2:obj.numberOfSteps

        % Advance the position of the ray
        obj.position(step,:) = obj.position(step-1,:) + (obj.direction .* obj.distancePerStep);

        % Check for object edge intersections
        found_intersection = false;

        for sceneObjs = 1:length(scene)
          n_edges = size(scene{sceneObjs}.position,1);
          for j = 1:n_edges
            if found_intersection
              continue;
            endif

            [intersects_edge, intersection_point] = obj.line_segment_intersection(obj.position(step-1,:), obj.position(step,:),...
                                                                           scene{sceneObjs}.position(j,:), scene{sceneObjs}.position(mod(j, n_edges) + 1, :));
            % If an intersection is detected, then set the flag
            if intersects_edge
              found_intersection = true;
              objectIndex = sceneObjs;
              edgeIndex = j;
            endif
          endfor
        endfor

        if found_intersection
            % Compute vector form of snells law
            light_vector = intersection_point - obj.position(step-1,:);
            light_vector = light_vector ./ norm(light_vector);
            surface_normal = scene{objectIndex}.normal(edgeIndex,:);

            cos_theta_1 = dot(-surface_normal,light_vector);
            if cos_theta_1 < 0
              surface_normal = -surface_normal;
              cos_theta_1 = dot(-surface_normal,light_vector);
            endif

            reflect_vector = light_vector + (2*cos_theta_1*surface_normal);

            % For refraction, we need to get the indices of refraction by
            % looping through each object in the scene to infer the IoR
            n1 = obj.currentIoR;
            n2 = 1.0;

            for i = 1:length(scene)
              is_inside = obj.point_in_polygon(obj.position(step,:), scene{i}.position);

              if is_inside
                n2 = scene{i}.indexOfRefraction;
                break;
              endif
            endfor

            sin_theta_2 = (n1 ./ n2).*sqrt(1 - (cos_theta_1.^2));

            radicand = 1 - (sin_theta_2.^2);

            cos_theta_2 = sqrt(1 - (sin_theta_2.^2));
            refract_vector = ((n1/n2).*light_vector) + ((((n1/n2)*cos_theta_1) - cos_theta_2).*surface_normal);

            % Update position using the intersection point and
            % direction vector based on results and material

            if scene{objectIndex}.reflective || radicand < 0
              obj.direction = reflect_vector;
            else
              obj.direction = refract_vector;
              obj.currentIoR = n2;
            endif

            % Update ray position
            obj.position(step,:) = intersection_point;
        endif
      endfor
    endfunction

    % Render
    function render(obj)
      hold(gca,'on');
      plot(gca, obj.position(:,1), obj.position(:,2),'r-');
      hold(gca,'off');
    endfunction

    function inside = point_in_polygon(obj, point, polygon_vertices)
      % point = (x, y) - the point to check
      % polygon = an Nx2 matrix of vertices [x1, y1; x2, y2; ...; xn, yn]

      % Extract the coordinates of the point
      x = point(1);
      y = point(2);

      % Get the number of vertices of the polygon
      n = size(polygon_vertices, 1);

      % Initialize the number of intersections
      intersections = 0;

      for i = 1:n
        % Get the current edge from the polygon
        x1 = polygon_vertices(i, 1);
        y1 = polygon_vertices(i, 2);
        x2 = polygon_vertices(mod(i, n) + 1, 1);  % Wrap around for the last vertex
        y2 = polygon_vertices(mod(i, n) + 1, 2);  % Wrap around for the last vertex

        % Check if the ray from point (x, y) intersects the edge (x1, y1) → (x2, y2)
        if ((y1 > y && y2 <= y) || (y2 > y && y1 <= y))  % Check if the point's y is between the edge's y-values
          % Calculate the x-coordinate of the intersection point of the ray with the edge
          intersect_x = (y - y1) * (x2 - x1) / (y2 - y1) + x1;

          % Check if the intersection point is to the right of the point
          if (intersect_x > x)
            intersections = intersections + 1;
          endif
        endif
      endfor

      % If the number of intersections is odd, the point is inside
      inside = mod(intersections, 2) == 1;
    endfunction

    function [intersect, intersection_point] = line_segment_intersection(obj, A, B, C, D)
      % Compute the differences between points
      dx1 = B(1) - A(1);
      dy1 = B(2) - A(2);
      dx2 = D(1) - C(1);
      dy2 = D(2) - C(2);

      % Set up the system of equations
      denom = (dx1 * dy2) - (dy1 * dx2);

      % If denom is 0, the lines are parallel or collinear
      if denom == 0
          intersect = false;
          intersection_point = [];
          return;
      endif

      % Compute the parameters t and u
      dx3 = C(1) - A(1);
      dy3 = C(2) - A(2);

      t = (dx3 * dy2 - dy3 * dx2) / denom;
      u = (dx3 * dy1 - dy3 * dx1) / denom;

      % Check if the intersection point is within both line segments
      if t > 0 && t < 1 && u > 0 && u < 1
          intersect = true;
          % Calculate the intersection point using t
          intersection_point = [A(1) + t * dx1, A(2) + t * dy1];
      else
          intersect = false;
          intersection_point = [];
      endif
    endfunction
  endmethods
endclassdef

