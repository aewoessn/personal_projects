clear, clc, close all

% Give the light some initial conditions
currentPosition = [-0.5, -0.75];
currentAngle = 45*(pi/180);
currentVector = [cos(currentAngle),sin(currentAngle)];
dDist = 0.01;

% Generate the environment
figure;
bounds = patch([-1.0, -1.0, 1.0, 1.0],[1.0, -1.0, -1.0, 1.0],'FaceColor','none','EdgeColor','k','Linewidth',1.5);
xlim([-1.0 1.0]);
ylim([-1.0 1.0]);

hold on;
s = scatter(currentPosition(1), currentPosition(2),'r','filled');
p = plot(currentPosition(1), currentPosition(2), 'r-');
q = quiver(currentPosition(1), currentPosition(2), currentVector(1)*0.1, currentVector(2)*0.1);
hold off;

% Begin the simulation
simDone = false;
numberOfTicks = 1;
while ~simDone

  % Advance the beam using the position and angle
  currentPosition = currentPosition + (currentVector*dDist);

  % Check to see if +/-x wall is hit
  if currentPosition(1) >= 1.0
    normVector = [-1.0, 0.0];
    currentVector = currentVector - (2*dot(currentVector,normVector).*normVector);
  elseif currentPosition(1) <= -1.0
    normVector = [1.0, 0.0];
    currentVector = currentVector - (2*dot(currentVector,normVector).*normVector);
  endif

  % Check to see if +/-y wall is hit
  if currentPosition(2) >= 1.0
    normVector = [0.0, -1.0];
    currentVector = currentVector - (2*dot(currentVector,normVector).*normVector);
  elseif currentPosition(2) <= -1.0
    normVector = [0.0, 1.0];
    currentVector = currentVector - (2*dot(currentVector,normVector).*normVector);
  endif

  % Update plot
  set(s,{'XData','YData'},{currentPosition(1),currentPosition(2)});
  set(p,{'XData','YData'},{[get(p,'XData'),currentPosition(1)],[get(p,'YData'),currentPosition(2)]});
  set(q,{'XData','YData','UData','VData'},{currentPosition(1), currentPosition(2), currentVector(1)*0.1, currentVector(2)*0.1});
  drawnow();

  % Advance the simulation by one tick
  numberOfTicks = numberOfTicks + 1;
end
