function [tout,rout] = wind_rose(theta,x)
%wind_rose.m   Angle histogram plot.

%   ROSE(THETA) plots the angle histogram for the angles in THETA.  
%   The angles in the vector THETA must be specified in radians.
%
%   ROSE(THETA,N) where N is a scalar, uses N equally spaced bins 
%   from 0 to 2*PI.  The default value for N is 20.
%
%   ROSE(THETA,X) where X is a vector, draws the histogram using the
%   bins specified in X.
%
%   [T,R] = ROSE(...) returns the vectors T and R such that 
%   POLAR(T,R) is the histogram.  No plot is drawn.
%
%   H = ROSE(...) returns a vector of line handles.
%
%   See also HIST, POLAR, COMPASS.

%   Clay M. Thompson 7-9-91
%   Copyright (c) 1984-97 by The MathWorks, Inc.
%   $Revision: 5.7 $  $Date: 1997/04/08 06:47:39 $
%


%----------------------------------------------------------------------------
%   Modified by Gordon Drewitt April 08, 1998
%
%   This modification plots the wind rose in the standard format.  
%   (north is at the top of the plot)

%   E.Humphreys Aug 8, 1999: took out text indicating # samples at the radial circles
%----------------------------------------------------------------------------



if isstr(theta)
        error('Input arguments must be numeric.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
theta = theta + 90*pi/180;%%% modified by G. Drewitt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

theta = rem(rem(theta,2*pi)+2*pi,2*pi); % Make sure 0 <= theta <= 2*pi
if nargin==1,
  x = (0:19)*pi/10+pi/20;

elseif nargin==2,
  if isstr(x)
        error('Input arguments must be numeric.');
  end
  if length(x)==1,
    x = (0:x-1)*2*pi/x + pi/x;
  else
    x = sort(rem(x(:)',2*pi));
  end

end
if isstr(x) | isstr(theta)
        error('Input arguments must be numeric.');
end
[nn,xx] = hist(theta,x);    % Get histogram

% Form radius values for histogram triangle
if min(size(nn))==1, % Vector
  nn = nn(:); 
 xx=xx(:);
end
[m,n] = size(nn);
mm = 4*m;
r = zeros(mm,n);
r(2:4:mm,:) = nn;
r(3:4:mm,:) = nn;

% Form theta values for histogram triangle from triangle centers (xx)
yy = [2*xx(1)-xx(2);xx;2*xx(m)-xx(m-1)];
zz = ([0;yy] + [yy;0])/2;
zz = zz(2:m+2,:);

t = zeros(mm,1);
t(2:4:mm) = zz(1:m);
t(3:4:mm) = zz(2:m+1);

if nargout<2
  h = polar_ros(t,r);
  if nargout==1, tout = h; end
  wind_mod
  return
end

if min(size(nn))==1,
  tout = t'; rout = r';
else
  tout = t; rout = r;
end
wind_mod

function wind_mod
set(gca,'xdir','rev');


%------------modified by G. Drewitt------------------------------------------------------
%   This section changes the labels around
%
h1=get(gca,'chi');
ind = find(strcmp(get(h1,'type'),'text'));
st='0';st1='W';ind1=strcmp(get(h1(ind),'string'),st);set(h1(ind(ind1)),'string',st1);
st='90';st1='N';ind1=strcmp(get(h1(ind),'string'),st);set(h1(ind(ind1)),'string',st1);
st='180';st1='E';ind1=strcmp(get(h1(ind),'string'),st);set(h1(ind(ind1)),'string',st1);
st='270';st1='S';ind1=strcmp(get(h1(ind),'string'),st);set(h1(ind(ind1)),'string',st1);
st='120';st1='111';ind1=strcmp(get(h1(ind),'string'),st);set(h1(ind(ind1)),'string',st1);
st='150';st1='222';ind1=strcmp(get(h1(ind),'string'),st);set(h1(ind(ind1)),'string',st1);
st='210';st1='120';ind1=strcmp(get(h1(ind),'string'),st);set(h1(ind(ind1)),'string',st1);
st='240';st1='150';ind1=strcmp(get(h1(ind),'string'),st);set(h1(ind(ind1)),'string',st1);
st='300';st1='210';ind1=strcmp(get(h1(ind),'string'),st);set(h1(ind(ind1)),'string',st1);
st='330';st1='240';ind1=strcmp(get(h1(ind),'string'),st);set(h1(ind(ind1)),'string',st1);
st='30';st1='300';ind1=strcmp(get(h1(ind),'string'),st);set(h1(ind(ind1)),'string',st1);
st='60';st1='330';ind1=strcmp(get(h1(ind),'string'),st);set(h1(ind(ind1)),'string',st1);
st='111';st1='30';ind1=strcmp(get(h1(ind),'string'),st);set(h1(ind(ind1)),'string',st1);
st='222';st1='60';ind1=strcmp(get(h1(ind),'string'),st);set(h1(ind(ind1)),'string',st1);
%------------------------------------------------------------------------------------------
