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

loopRange = 1:length(slow_waves_real);








