function  lh = hatch(obj,angle,color,width,step)

% HATCH  Hatchs a two-dimensional domain.
%     Slightly similar to the FILL command but fills the closed
%     contour with hatched lines instead of uniform color.
%     The boundary line must be created prior to this command
%     and its handle is specified by OBJ argument.
%   HATCH(OBJ) Hatchs the domain bounded by the Xdata and Ydata
%     properties of the OBJ (can be line or patch type).
%   HATCH by itself takes as OBJ the last object created in the 
%     current axes.
%   HATCH(OBJ,ANGLE,COLOR,WIDTH,STEP) Specifies additional
%     parameters:  slope of the hatches (in degrees),
%     their color ([red green blue]) and also the width of the
%     hatch lines (in points) and distance between hatches
%     (also in points).
%     All arguments optional but must be input in the given order.
%   LH = HATCH(OBJ) also returns the handle of the hatch line.
%
%     Example:  HATCH(L,30,[1 0 0],2,8)    Hatchs the domain
%     bounded by the contour L with red lines of 2-point thickness
%     and 8-point steps, inclined at 30 degrees to the x-axis.
%
%     See also FILL, LINE, PATCH

%  Kirill K. Pankratov,  kirill@plume.mit.edu
%  March 27 1994

 % Defaults ............
angledflt = 45;        % Angle in degrees
colordflt = [1 1 1];   % Color
widthdflt = 1;         % Thickness of the lines
stepdflt = 10;         % Distance between hatches

if angle == 90 | angle == 0
   angle = angle - 0.0001;
end


% Handle input .................................................
if nargin==0
  ch = get(gca,'child');
  if ch~=[], obj = ch(1);
  else
    disp([10 '  Error: no object to hatch is found ' 10])
    return
  end
end
if nargin<5, step = stepdflt; end
if nargin<4, width = widthdflt; end
if nargin<3, color = colordflt; end
if nargin<2, angle = angledflt; end
typ = get(obj,'type');
if ~(strcmp(typ,'line')|strcmp(typ,'patch'))
  disp([10 '  Error: object must be either line or patch ' 10])
  return
end

angle = angle*pi/180;                       % Degrees to radians
x = get(obj,'xdata'); y = get(obj,'ydata'); % Get x,y
x = [x(:)' x(1)]; y = [y(:)' y(1)];         % Close loop
ll = length(x);

 % Transform the coordinates .............................
oldu = get(gca,'units');
set(gca,'units','points')
sza = get(gca,'pos'); sza = sza(3:4);
xlim = get(gca,'xlim');
ylim = get(gca,'ylim');
islx = strcmp(get(gca,'xscale'),'log');
isly = strcmp(get(gca,'yscale'),'log');
if islx   % If log scale in x
  xlim = log10(xlim);
  x = log10(x);
end
if isly   % If log scale in y
  ylim = log10(ylim);
  y = log10(y);
end
xsc = sza(1)/(xlim(2)-xlim(1)+eps);
ysc = sza(2)/(ylim(2)-ylim(1)+eps);

ca = cos(angle); sa = sin(angle);
x0 = mean(x); y0 = mean(y);  % Central point
x = (x-x0)*xsc; y = (y-y0)*ysc;
yi = x*ca+y*sa;  % Rotation
y = -x*sa+y*ca;
x = yi;
y = y/step;    % Make steps equal to one

 % Compute the coordinates of the hatch line ...............
yi = ceil(y);
ll = length(y);
yd = [yi(2:ll)-yi(1:ll-1) 0];
dm = max(abs(yd));
fnd = find(yd);
lfnd = length(fnd);
A = sign(yd(fnd));
edm = ones(dm,1);
A = A(edm,:);
if size(A,1)>1, A = cumsum(A); end
fnd1 = find(abs(A)<=abs(yd(edm,fnd)));
A = A+yi(edm,fnd)-(A>0);
xy = (x(fnd+1)-x(fnd))./(y(fnd+1)-y(fnd));
xi = x(edm,fnd)+(A-y(edm,fnd)).*xy(edm,:);
yi = A(fnd1);
xi = xi(fnd1);

 % Sorting points of the hatch line ........................
li = length(xi); 
xi0 = min(xi); xi1 = max(xi);
yi0 = min(yi); yi1 = max(yi);
ci = yi*(xi1-xi0)+xi;
[ci,num] = sort(ci);
xi = xi(num); yi = yi(num);
if floor(li/2)~=li/2
  xi = [xi xi(li)];
  yi = [yi yi(li)];
end
 % Organize to pairs and separate by  NaN's ................
li = length(xi);
xi = reshape(xi,2,li/2);
yi = reshape(yi,2,li/2);
xi = [xi; ones(1,li/2)*nan];
yi = [yi; ones(1,li/2)*nan];
xi = xi(:)'; yi = yi(:)';

ind = find(diff(xi)==0);
xi([ind ind+1]) = NaN;
yi([ind ind+1]) = NaN;
 % Transform to the original coordinates ...................
yi = yi*step;
xy = xi*ca-yi*sa;
yi = +xi*sa+yi*ca;
xi = xy/xsc+x0;
yi = yi/ysc+y0;
if islx, xi = 10.^xi; end
if isly, yi = 10.^yi; end


 % Now create a line to hatch .............................
lh = line('xdata',xi,'ydata',yi,'linewidth',width,'color',color);
set(gca,'units',oldu)

