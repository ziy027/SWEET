% SW Travelling analysis

GS = 58; % globality factor

load('ChannelLocs.mat'); % no E1, E2 locations
c=find(ismember({locs.labels},[s.chlist]));
                locs = locs(c);

Th = pi/180*[locs.theta];        % Calculate theta values from x,y,z e_loc
Rd = [locs.radius];              % Calculate radian values from x,y,z e_loc

x = Rd.*cos(Th);                 % Calculate 2D projected X
y = Rd.*sin(Th);                 % Calculate 2D projected Y

x = x(:);
x = x-min(x); 
x = num2cell(((x/max(x))*(GS-1))+1);

y = y(:);
y = y-min(y); 
y = num2cell(((y/max(y))*(GS-1))+1);

xloc = [x{:}]; xloc=xloc(:);
yloc = [y{:}]; yloc=yloc(:);

XYrange = linspace(1, GS, GS);
XYmesh = XYrange(ones(GS,1),:);

% only do the follwing steps on real SWs, regardless of methods 
mnp = find([s.slow_waves_MNP.overlap_blink] == 0);
zx = find([s.slow_waves_ZX.overlap_blink] == 0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% construction



%% check Matlab version for interpolant...
        % If its available use the newest function
        slow_waves_real = [s.slow_waves_ZX(177)];
        F = scatteredInterpolant(xloc, yloc, slow_waves_real.Travelling_Delays_thr(1:end),...
            'natural', 'none');
        interp_version = 1;


loopRange = 1:length(slow_waves_real);

for n = loopRange

    Delays = slow_waves_real(n).Travelling_Delays_thr(1:end);
    Delays = Delays(:); % ensure data is in column format
    F.Values = Delays;
        
        slow_waves_real(n).Travel_Map = F(XYmesh, XYmesh'); % Delay map (with zeros)

% Define Starting Point(s) on the GSxGS grid...
        sx = xloc(slow_waves_real(n).Channels_Active_corr(1:end));
        sy = yloc(slow_waves_real(n).Channels_Active_corr(1:end));
end

% calculate the gradients over the delay map
    [u,v] = gradient(slow_waves_real(n).Travel_Map);

   
% Use adstream2 
    % TODO: optimise by coding entire loop in C
    Streams         = cell(1,length(sx));
    Distances       = cell(1,length(sx));
    for n = 1:length(sx)
        % find streams backwards from current point
        [StreamsBack, DistancesBack,~] = adstream2b(...
            XYrange,XYrange,-u,-v,sx(n),sy(n), cosd(45), 0.1, 1000);
        % find streams forward from current point
        [StreamsForw, DistancesForw,~] = adstream2b(...
            XYrange,XYrange,u,v,sx(n),sy(n), cosd(45), 0.1, 1000);
        % combine the two directions for continuous stream
        Streams{n}      = [fliplr(StreamsBack), StreamsForw];
        Distances{n}    = [fliplr(DistancesBack), DistancesForw];
    end

    Streams(cellfun(@isempty, Streams)) = []; %Remove empty streams
    Distances(cellfun(@isempty, Distances)) = []; %Remove empty streams
    
    
    % Minimum Distance Threshold (25% of longest path)
    tDist = cellfun(@(x) sum(x), Distances);    %% Plot Functions
    Streams(tDist < max(tDist)/4) = [];
    Distances(tDist < max(tDist)/4) = [];
   
    % Longest displacement
    tDisp = cellfun(@(x) (sum((x(:,1)-x(:,end)).^2))^0.5, Streams); % total displacement
    [~,maxDispId] = max(tDisp);
    slow_waves_real(n).Travelling_Streams{1} = Streams{maxDispId};
    
    % Longest distance travelled (if different from displacement)
    tDist = cellfun(@(x) sum(x), Distances);    %% Plot Functions
    [~,maxDistId] = max(tDist);
    if maxDistId ~= maxDispId
        slow_waves_real(n).Travelling_Streams{end+1} = Streams{maxDistId};
    end  

    % Most different displacement angle compared to longest stream (at least 45 degrees)
    streamAngle = cellfun(@(x) atan2d(x(1,end)- x(1,1),x(2,end)-x(2,1)), Streams);
    [maxAngle,maxAngleId] = max(streamAngle - streamAngle(maxDispId));
    if maxAngle > 45 || maxAngleId ~= maxDispId || maxAngleId ~= maxDistId
        slow_waves_real(n).Travelling_Streams{end+1}  = Streams{maxAngleId};
    end

 h = plt_slow_waves(slow_waves_real,58, Streams);






