clear, clc, close all

% Give the light some initial conditions
currentPosition = [-0.5, -0.75];
currentAngle = 30*(pi/180);
currentVector = [cos(currentAngle),sin(currentAngle)];
dDist = 0.05;

% Generate the environment
figure;
glass = patch([0.0, 0.0, 1.0, 1.0],[1.0, -1.0, -1.0, 1.0],'FaceColor','blue','FaceAlpha',0.2,'EdgeColor','none');
bounds = patch([-1.0, -1.0, 1.0, 1.0],[1.0, -1.0, -1.0, 1.0],'FaceColor','none','EdgeColor','k','Linewidth',1.5);
xlim([-1.0 1.0]);
ylim([-1.0 1.0]);

hold on;
s = scatter(currentPosition(1), currentPosition(2),'r','filled');
p = plot(currentPosition(1), currentPosition(2), 'r-');
q = quiver(currentPosition(1), currentPosition(2), currentVector(1)*0.1, currentVector(2)*0.1);
hold off;

% Give physical properties
airIOR = 1.0;
glassIOR = 1.52;

% Begin the simulation
simDone = false;
numberOfTicks = 1;
while ~simDone

  % Advance the beam using the position and angle
  nextPosition = currentPosition + (currentVector.*dDist);

  % Check for transitions
  if nextPosition(1) > 0.0 && currentPosition(1) < 0.0
    % Transition from air (left) to glass (right)

    % Solve the equation: n_1 * sin(theta_1) = n_2 * sin(theta_2)
    % sin(theta_2) = (n_1 * sin(theta_1)) / n_2

    currentAngle = asin((airIOR * sin(currentAngle)) / glassIOR);
    currentVector = [cos(currentAngle),sin(currentAngle)].*sign(currentVector);

    % Update projected position
    currentPosition = currentPosition + (currentVector.*dDist);
  elseif nextPosition(1) < 0.0 && currentPosition(1) > 0.0

    % Transition from glass (right) to air (left)
    incidentAngle = asin((glassIOR * sin(currentAngle)) / airIOR)

    % Check for total internal reflection
    criticalAngle = real(asin(airIOR / glassIOR))
    if incidentAngle > criticalAngle
      normVector = [1.0, 0.0];
      currentVector = currentVector - (2*dot(currentVector,normVector).*normVector);
    else
      currentAngle = incidentAngle;
      currentVector = [cos(currentAngle),sin(currentAngle)].*sign(currentVector);
    endif

    currentPosition = currentPosition + (currentVector.*dDist);
  else
    currentPosition = nextPosition;
  endif

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

