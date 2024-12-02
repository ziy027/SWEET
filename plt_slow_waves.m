function h = plt_slow_waves(slow_waves_real,GS,Streams)

load('ChannelLocs.mat'); % no E1, E2 locations
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
n=1;

XYrange = linspace(1, GS, GS);
XYmesh = XYrange(ones(GS,1),:);

h = struct;
h.figure = figure;
hold on

set(h.figure,...
    'Color',            'w'                 );
h.CurrentAxes = axes(h.figure,'Position',[0 0 1 1]);
colormap parula
NumContours = 9;

h.Surface = surf(h.CurrentAxes, XYmesh ,XYmesh', zeros(size(slow_waves_real(n).Travel_Map)), slow_waves_real(n).Travel_Map');
    set(h.Surface,...
        'EdgeColor',        'none'              ,...
        'FaceColor',        'interp'            ,...
        'HitTest',          'off'               );

 LevelList   = linspace(min(slow_waves_real(n).Travel_Map(:)), max(slow_waves_real(n).Travel_Map(:)), NumContours);
 [~,h.Contour] = contourf(h.CurrentAxes, XYmesh,XYmesh',slow_waves_real(n).Travel_Map');
    set(h.Contour,...
        'LineWidth',        .1        ,...
        'LevelList',        LevelList           ,...
        'HitTest',          'off'               );

%% plot head
r = GS/2.5;
    center = GS/2;

    % Head
    ang     = 0:0.01:2*pi;
    xp      = center+(r*cos(ang));
    yp      = center+(r*sin(ang));

    % Nose...
    base    = 0.4954;
    basex   = 0.0900;                 % nose width
    tip     = 0.5750;
    tiphw   = 0.02;                   % nose tip half width
    tipr    = 0.005;                  % nose tip rounding

    % Ears...
    q       = .004; % ear lengthening
    EarX  = [0.497-.005  0.510        0.518        0.5299       0.5419       0.54         .547        .532        .510    .489-.005]; % rmax = 0.5
    EarY  = [q+0.0555    q+0.0775     q+0.0783     q+0.0746     q+0.0555     -0.0055      -.0932      -.1313      -.1384  -.1199];

    % Plot the head
    hold on
    h.Head(1) = plot(h.CurrentAxes, xp, yp);
    h.Head(2) = plot(h.CurrentAxes,...
             center+r*2*[basex;tiphw;0;-tiphw;-basex],center+r*2*[base;tip-tipr;tip;tip-tipr;base]);

    h.Head(3) = plot(h.CurrentAxes,...
                    center+r*2*EarX,center+r*2*EarY);% plot left ear
    h.Head(4) = plot(h.CurrentAxes,...
                    center+r*2*-EarX,center+r*2*EarY);   % plot right ear

    % Set the head properties
    set(h.Head,...
        'Color',            [0,0,0]           ,...
        'LineWidth',        2.5           ,...
        'HitTest',          'off'               );

labels    = {locs([1:24,33:end]).labels};
    for i = 1:size(labels,2)
        h.Channels(i) = text(xloc(i),yloc(i), '.'         ,...
            'userdata',         char(labels(i))         ,...
            'Parent',           h.CurrentAxes           );
    end

set(h.Channels                              ,...
        'HorizontalAlignment',  'center'        ,...
        'VerticalAlignment',    'middle'        ,...
        'Color',                'k'             ,...
        'FontSize',             10              ,...
        'FontWeight',           'bold'          );

    set(h.Channels                              ,...
        'buttondownfcn', ...
	    ['tmpstr = get(gco, ''userdata'');'     ...
	     'set(gco, ''userdata'', get(gco, ''string''));' ...
	     'set(gco, ''string'', tmpstr); clear tmpstr;'] );


for i = 1:length(Streams)
    if ~isempty(Streams{i})
        pad = linspace(0, GS/50, length(Streams{i}));
        yp  = [Streams{i}(1,:)-pad, fliplr(Streams{i}(1,:)+pad)];
        xp  = [Streams{i}(2,:)+pad, fliplr(Streams{i}(2,:)-pad)];
        h.PStream(i) = patch(xp,yp,[.5 .5 .5],'LineStyle','none', 'Parent', h.CurrentAxes);
        alpha(0.7)
    end
end

% Adjustments
% square axes
set(h.CurrentAxes, 'PlotBoxAspectRatio', [1, 1, 1],'visible', 'off');
% hide the axes
set(h.CurrentAxes, 'visible', 'off');

