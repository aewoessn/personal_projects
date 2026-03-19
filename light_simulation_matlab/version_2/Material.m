classdef Material < handle

  properties
    position;
    midpoint;
    normal;
    tform;
    indexOfRefraction;
    reflective = false;
    displayColor = [0.0, 0.0, 0.0, 1.0];
    name;
    showNormals = false;
  endproperties

  methods
    % Constructor
    function obj = Material(varargin)

      % Set up initial parameters
      position = [-0.5, 0.5, 0.5, -0.5; 0.01, 0.01, -0.01, -0.01];
      translation = [0,0];
      rotation = 0;
      scale = [1,1];

      % Parse inputs
      for i = 1:2:nargin
        switch tolower(varargin{i})
          case 'position'
            position = varargin{i+1};
          case 'translation'
            translation = varargin{i+1};
          case 'rotation'
            rotation = varargin{i+1};
          case 'scale'
            scale = varargin{i+1};
          case 'reflective'
            obj.reflective = varargin{i+1};
          case 'indexofrefraction'
            obj.indexOfRefraction = varargin{i+1};
          case 'displaycolor'
            obj.displayColor = varargin{i+1};
          case 'shownormals'
            obj.showNormals = varargin{i+1};
        endswitch
      endfor

      % Add extra row to position for transformation matrix
      position = cat(1, position, ones(1,size(position,2)));

      % Apply scale
      scaleTform = eye(3);
      scaleTform(1,1) = scale(1);
      scaleTform(2,2) = scale(2);

      % Apply rotation
      rotTform = eye(3);
      rotTform(1,1) = cos(rotation);
      rotTform(1,2) = -sin(rotation);
      rotTform(2,1) = sin(rotation);
      rotTform(2,2) = cos(rotation);

      % Apply translation
      transTform = eye(3);
      transTform(1:2,3) = translation;

      % Multiply everything together
      obj.tform = transTform*rotTform*scaleTform;
      obj.position = obj.tform*position;
      obj.position = obj.position(1:2,:)';

      % Compute midpoints
      obj.midpoint = (obj.position + circshift(obj.position,-1,1))./2;

      % Compute normals
      for i = 1:size(obj.position, 1)
          % Get the current edge of the polygon
          p1 = obj.position(i,:);
          p2 = obj.position(mod(i, size(obj.position, 1)) + 1, :); % Next vertex (wrapping around)

          % Calculate the normal vector to the polygon edge
          edge_vector = p2 - p1;
          obj.normal(i,:) = [-edge_vector(2), edge_vector(1)]; % Perpendicular to edge_vector
          obj.normal(i,:) = obj.normal(i,:) ./ norm(obj.normal(i,:));
      end

      % Verify normals
      obj.check_normals();

      % Render
      obj.render();
    endfunction

    function render(obj)
        hold(gca,'on');
        patch(gca, obj.position(:,1), obj.position(:,2), 'FaceColor', obj.displayColor(1:3),'FaceAlpha',obj.displayColor(end), 'EdgeColor','k');
        %patch(gca, obj.position(:,1), obj.position(:,2), 'EdgeColor','k', 'FaceColor','none');

        if obj.showNormals
          for i = 1:size(obj.normal,1)
            plot([obj.midpoint(i,1),obj.midpoint(i,1) + (obj.normal(i,1)*0.1)],...
                  [obj.midpoint(i,2),obj.midpoint(i,2) + (obj.normal(i,2)*0.1)],'k');
          endfor
        endif

        hold(gca,'off');
    endfunction

    function check_normals(obj)
      % Check if the normal of a 2D polygon points outward or inward
      % vertices: An nx2 matrix where each row is a 2D coordinate of a vertex (x, y)

      % Get the vertices
      vertices = obj.position;

      % Ensure the vertices are in a proper format: a Nx2 matrix (each row is a vertex)
      if size(vertices, 2) ~= 2
        error("Vertices must be a matrix with 2 columns (x, y).");
      end

      % Get the number of vertices
      n = size(vertices, 1);

      % Compute the signed area using the shoelace formula (Gauss's area formula)
      signed_area = 0;
      for i = 1:n
        j = mod(i, n) + 1;  % j is the next vertex (wrap around to the first vertex)
        signed_area = signed_area + (vertices(i, 1) * vertices(j, 2)) - (vertices(j, 1) * vertices(i, 2));
      end
      signed_area = signed_area / 2;

      % Check if the signed area is positive or negative to determine winding order
      if signed_area < 0
        % Normals are outward
        obj.normal = obj.normal;
        %fprintf("The normal is pointing OUTWARD (counterclockwise winding order).\n");
      elseif signed_area > 0
        % Normals are inward
        obj.normal = -obj.normal;
        %fprintf("The normal is pointing INWARD (clockwise winding order).\n");
      else
        fprintf("The polygon has zero area (invalid polygon or degenerate case).\n");
      end
    endfunction

  endmethods
 endclassdef
