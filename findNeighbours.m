function [channels] = findNeighbours(locs)
x = find(~cellfun(@isempty,{locs.X}));
x(25:26) = [];
nCh = length(x);

indices = 1:length(locs);
indices = indices(x);

x = [locs(indices).X ]'; 
y = [locs(indices).Y ]';
z = [locs(indices).Z ]';

vertices = [x,y,z];

z2 = z - max(z);
hypotxy = hypot(x,y);
R = hypot(hypotxy,z2);
PHI = atan2(z2,hypotxy);
TH = atan2(y,x);

% Remove the too small values for PHI
PHI(PHI < 0.001) = 0.001;

% Flat projection
R2 = R ./ cos(PHI) .^ .2;
X = R2.*cos(TH);
Y = R2.*sin(TH);

mass = mean(vertices);
diffvert = bsxfun(@minus, vertices, mass); 
R0 = mean(sqrt(sum(diffvert.^2, 2)));
% Optimization
vec0 = [mass,R0];
minn = fminsearch(@dist_sph, vec0, [], vertices);

HeadCenter = minn(1:end-1); % 3x1

coordC = bsxfun(@minus, vertices, HeadCenter);
coordC = bsxfun(@rdivide, coordC, sqrt(sum(coordC.^2,2)));
coordC = bsxfun(@rdivide, coordC, sqrt(sum(coordC.^2,2)));

faces  = convhulln(coordC);

% Get border of the representation
border = convhull(X,Y);
%plot(X(border),Y(border),'r-',X,Y,'b+')

% Keep faces inside the border
iInside = ~(ismember(faces(:,1),border) & ismember(faces(:,2),border)& ismember(faces(:,3),border));
faces   = faces(iInside, :);

my_norm = @(v)sqrt(sum(v .^ 2, 2)); % creates an object
% Get coordinates of vertices for each face
vertFacesX = reshape(vertices(reshape(faces,1,[]), 1), size(faces));
vertFacesY = reshape(vertices(reshape(faces,1,[]), 2), size(faces));
vertFacesZ = reshape(vertices(reshape(faces,1,[]), 3), size(faces));
% For each face : compute triangle perimeter
triSides = [my_norm([vertFacesX(:,1)-vertFacesX(:,2), vertFacesY(:,1)-vertFacesY(:,2), vertFacesZ(:,1)-vertFacesZ(:,2)]), ...
    my_norm([vertFacesX(:,1)-vertFacesX(:,3), vertFacesY(:,1)-vertFacesY(:,3), vertFacesZ(:,1)-vertFacesZ(:,3)]), ...
    my_norm([vertFacesX(:,2)-vertFacesX(:,3), vertFacesY(:,2)-vertFacesY(:,3), vertFacesZ(:,2)-vertFacesZ(:,3)])];
triPerimeter = sum(triSides, 2);
% Threshold values
thresholdPerim = mean(triPerimeter) + 3 * std(triPerimeter);
% Apply threshold
faces(triPerimeter > thresholdPerim, :) = [];

figure( 'Color',       'w'     ,...
    'Position',    [50,50, 500, 500]  );

axes  ( 'Color',      'w' );

FaceColor = [.5 .5 .5];
EdgeColor = [0 0 0];
FaceAlpha = .9;
LineWidth = 1;

hNet = patch('Vertices',        vertices, ...
    'Faces',           faces, ...
    'FaceVertexCData', repmat([1 1 1], [length(vertices), 1]), ...
    'Marker',          'o', ...
    'LineWidth',       LineWidth, ...
    'FaceColor',       FaceColor, ...
    'FaceAlpha',       FaceAlpha, ...
    'EdgeColor',       EdgeColor, ...
    'EdgeAlpha',       1, ...
    'MarkerEdgeColor', [0 0 0], ...
    'MarkerFaceColor', 'flat', ...
    'MarkerSize',      12, ...
    'BackfaceLighting', 'lit', ...
    'Tag',             'SensorsPatch');
material([ 0.5 0.50 0.20 1.00 0.5 ])
lighting phong
% Set Constant View Angle
view(48,15);
axis equal
% cameratoolbar('Show')
rotate3d on
axis off
    
% loop through all the channels
output = cell(nCh,1);
for n = 1 : nCh
   
    [r1, ~] = ind2sub(size(faces), find(faces == n));
    output{n} = unique(faces(r1, :)')';
    
end

nz=max(cellfun(@numel,output));
channels = cell2mat(cellfun(@(a) [a,zeros(1,nz-numel(a))],output,'uni',false));

end
function d = dist_sph(vec,sensloc)
R = vec(end);
center = vec(1:end-1);
% Average distance between the center if mass and the electrodes
diffvert = bsxfun(@minus, sensloc, center);
d = mean(abs(sqrt(sum(diffvert.^2,2)) - R));
end