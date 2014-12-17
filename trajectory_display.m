function traj = trajectory_display( traj, options)
%TRAJECTORY_DISPLAY Plots a given smoothed trajectory in 3D.
close('all');
% Plot colors:
col = distinguishable_colors(3*length(traj.waypoints));
% Figures:
mainfigure = figure;
figure(mainfigure);

if isfield(traj, 'splines')
    % Plot splines:
    hold off;
    % Iterate over splines, plot series of points for each one:
    splinepoints = [];
    t = 0:0.01:1;
    for i=1:length(traj.splines)
        spline = traj.splines{i};
        
        for j=1:length(t)
            splinepoints = [splinepoints; trajectory_evaluateBezier(spline, t(j))'];
        end
        plot3(splinepoints(:, 1), splinepoints(:, 2), splinepoints(:, 3),...
            'Displayname', ['spline ' num2str(i)], 'color', col(i, :));
        splinepoints = [];
        
        hold on;
        if optionisset(options, 'controlpointsvisible')
            controlpoints = [spline.p1'; spline.p2'; spline.p3'; spline.p4'];
            plot3(controlpoints(:, 1), controlpoints(:, 2), controlpoints(:, 3),...
                'Displayname', ['control points spline ' num2str(i)], 'color', col(i, :), 'Marker', 'o');
        end
    end
end

% Plot waypoints:
% Copy waypoints to array for plotting:
if optionisset(options, 'waypointsvisible')
    wpoints = [];
    for i=1:length(traj.waypoints)
        wpoints(end+1, :) = traj.waypoints{i};
    end
    plot3(wpoints(:, 1), wpoints(:, 2), wpoints(:, 3),...
        'Displayname', 'waypoints', 'Marker', 'o');
end

% Plot discrete points:
if optionisset(options, 'discretepointsvisible') && isfield(traj, 'discrete')
    plot3(traj.discrete.points(:, 1), traj.discrete.points(:, 2), traj.discrete.points(:, 3),...
        'Displayname', 'discrete points', 'Marker', 'x');
end

% Plot spline derivatives:
if optionisset(options, 'firstderivativevisible') || optionisset(options, 'secondderivativevisible')
    % Iterate over spline length, get position, and first and second
    % derivatives.
    ds = 1;
    p = zeros(ceil(traj.sTotal/ds), 3);
    dp = zeros(ceil(traj.sTotal/ds), 3);
    ddp = zeros(ceil(traj.sTotal/ds), 3);
    s = 0:ds:traj.sTotal;
    for i = 1:length(s)
        [p(1, :), dp(1, :), ddp(1, :)] = trajectory_get( traj, s(i));
    end
    
    if optionisset(options, 'firstderivativevisible')
        quiver3(p(:, 1),p(:, 2),p(:, 3),dp(:, 1),dp(:, 2),dp(:, 3))
    end
    
    if optionisset(options, 'secondderivativevisible')
        quiver3(p(:, 1),p(:, 2),p(:, 3),ddp(:, 1),ddp(:, 2),ddp(:, 3))
    end
    
    xlabel 'x'
    ylabel 'y'
    zlabel 'z'
    
    axs = ['x', 'y', 'z'];
    
    % Separate plots for derivatives?
    if optionisset(options, 'plotfirstderivativeseparately')
        dpFigure = figure;
        for i=1:3
            subplot(3,1,i);
            plot(s, dp(:, i));
            ylabel(['dp/ds ' axs(i)]);
        end
        xlabel 's'
    end
    
    if optionisset(options, 'plotsecondderivativeseparately')
        dppfigure = figure;
        for i=1:3
            subplot(4,1,i);
            plot(s, ddp(:, i));
            ylabel(['ddp/ds ' axs(i)]);
        end
        % Compute total acceleration
        acc = 
        subplot(4,1,4);
        plot(s, norm(ddp(:, i)));
        ylabel('|ddp/ds|');
        
        xlabel 's'
    end
    
end

% Plot osculating circle?
if optionisset(options, 'plotosculatingcircle') && optionexists(options, 'sCircle')
    figure(mainfigure);
    % Figure out where to plot the circle:
    if options.sCircle > traj.sTotal
        options.sCircle = traj.sTotal;
    end
    [p, dp, ddp] = trajectory_get( traj, options.sCircle);
    r = 1/norm(ddp);
    center = p + r * fflib_normalize(cross(dp, [0 0 -1]'));
    hold on
    th = 0:pi/50:2*pi;
    x = r * cos(th) + center(1);
    y = r * sin(th) + center(2);
    z = center(3) * ones(size(y));
    h = plot3(x, y, z);
end


plotbrowser on;

    function result = optionisset(options, field)
        result = false;
        if isfield(options, field)
            result = options.(field);
        end
    end

    function result = optionexists(options, field)
        result = isfield(options, field);
    end

end
