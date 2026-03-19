classdef Block
  properties
    position;
    rotation;
    color;
    vertPosition;
    facePosition;
    faceNormals;
  endproperties

  properties(Access=private)

  endproperties

  methods
    function obj = Block(nSides)

      % Generate regular polygon
      degrees=2*pi/nSides;
      theta=0:degrees:2*pi;
      radius=ones(1,numel(theta));
      [obj.vertPosition(1,:),obj.vertPosition(2,:)] = pol2cart(theta,radius);

      % Calculate normals
      for i = 1:nSides
        facePosition(:,i) = mean(vertPosition(:,i:i+1),2);
        faceNormal(:,i) = flipud(vertPosition(:,i+1) - vertPosition(:,i));
        faceNormal(1,i) = -faceNormal(1,i);
        faceNormal(:,i) = faceNormal(:,i) ./ vecnorm(faceNormal(:,i))
      endfor
    endfunction
  endmethods
endclassdef
