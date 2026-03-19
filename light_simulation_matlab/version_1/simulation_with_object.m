clear, clc, close all
clear functions

% Initialize axis
figure; xlim([-2 2]); ylim([-2 2]);

% Create geometry for scene
%--- Glass ---%
scene{1} = Material('position',[0.5, 0.5, -0.5, -0.5; 0.5, -0.5, -0.5, 0.5],...
                    'rotation',0*pi/180,...
                    'indexOfRefraction',1.52,...
                    'color',[0.0, 0.0, 1.0, 0.2]);

%{
%--- Smooth concave polygon ---%
sides=200;
radius=1;
concave_factor=0.3;
smooth_factor=0.2;
  % Generate angles for the polygon vertices
  angles = linspace(0, 2 * pi, sides + 1);

  % Generate the outer boundary of the polygon
  outer_x = radius * cos(angles);
  outer_y = radius * sin(angles);

  % Apply a smooth concave perturbation to the polygon
  for i = 1:sides
    % Calculate a smooth sinusoidal factor to create concavity
    perturbation = concave_factor * sin(i * smooth_factor);

    % Apply the perturbation to the radius
    outer_x(i) = outer_x(i) * (1 + perturbation);
    outer_y(i) = outer_y(i) * (1 + perturbation);
  end
scene{1} = Mirror('position',[outer_x;outer_y]);
%}

%{
%--- Outer boundaries ---%
scene{1} = Mirror('translation',[-2,0],'rotation',90*pi/180,'scale',[3.985,1]);
scene{2} = Mirror('translation',[2,0],'rotation',90*pi/180,'scale',[3.985,1]);
scene{3} = Mirror('translation',[0,-2],'rotation',0*pi/180,'scale',[3.985,1]);
scene{4} = Mirror('translation',[0,2],'rotation',0*pi/180,'scale',[3.985,1]);
%}

%{
%--- Triangle ---%
scene{1} = Mirror('position',[-0.5,0.5,0.0;-0.5,-0.5,0.5],'rotation',70*pi/180);
scene{2} = Mirror('position',[0.0,0.5,-0.5;0.5,-0.5,-0.5],'translation',[-1.0,1.0]);
%}

%--- Concave polygon ---%
%scene{1} = Mirror('position',[0.5,0.0,0.5,-0.5,-0.5;0.5,0.0,-0.5,-0.5,0.5],'rotation',10*pi/180,'translation',[0.0,0.35]);

%--- Two mirrors ---%
%scene{1} = Mirror('translation',[0,0],'rotation',0*pi/180);
%scene{2} = Mirror('translation',[-1,1],'rotation',80*pi/180);

% Attach scene data to figure
% This is a hacky way to allow the ray object to access what is in the current scene
set(gca,'userdata',scene);

% Create (and cast) rays
%Ray([0.8, 0.6], 215*pi/180);
Ray([-0.7, -0.5], 70*pi/180);
%Ray([0.6, 0.8], 215*pi/180);

