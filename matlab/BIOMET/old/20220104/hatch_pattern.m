function [h_patch,h_out] = hatch_pattern(h_patch,pattern_no)
%HATCH_PATTERN Hatch a patch with a pattern.
%
%    HATCH_PATTERN(H,N) sets the patch color to none and hatches 
%    the patch identified by object handle H using pattern number N
%    in the original patch color. 
%    The following patterns are available:
%
%    N		 Width   Hatch
%    ----------------------------------
%     1      narrow  45deg upward
%     2      narrow  horizontal
%     3      narrow  45ded downward
%     4      narrow  45deg cross-hatch
%     5      narrow  45deg vertical
%     6      narrow  90deg cross-hatch
%     7      wide    45deg upward
%     8      wide    horizontal
%     9      wide    45ded downward
%    10      wide    45deg cross-hatch
%    11      wide    45deg vertical
%    12      wide    90deg cross-hatch
%
%    HATCH_PATTERN(H) hatches H with pattern 1.
%
%    [H,L] = HATCH_PATTERN(H,N) returns the modified patch handle H and 
%    a line object handle that describes the hatch lines.
%
%    See also HATCH, HATCH_BAR.

%Define pattern
angles = [[45 45]; [0 0]; [-45 -45]; [45 -45]; [90 0]; [90 90]; ...
          [45 45]; [0 0]; [-45 -45]; [45 -45]; [90 0]; [90 90];];
width  = 1;
step   = [1.5 2 1.5 2 2 1.5 3 4 3 4 4 3];

% Get patch color information
[m] = length(colormap);
cmap = colormap;
faceC = get(h_patch,'FaceColor');
v = caxis; 
if ischar(faceC) & strcmp(faceC,'flat')
   C = get(h_patch,'FaceVertexCData'); 
   index = fix((C(1)-v(1))/(v(2)-v(1))*m)+1;
   if index >= m, index = m; elseif index <= 1, index = 1; end
   col = cmap(index,:);
else
   col = faceC;
end

% Change patch color and do hatching
set(h_patch,'FaceColor','none','EdgeColor',col);
h = hatch(h_patch,angles(pattern_no,1),col,width,step(pattern_no));
if angles(pattern_no,1)~=angles(pattern_no,2)
   h2 = hatch(h_patch,angles(pattern_no,2),col,width,step(pattern_no));
   x = [get(h,'xdata') get(h2,'xdata')];
   y = [get(h,'ydata') get(h2,'ydata')];
   set(h,'xdata',x,'ydata',y);
end

if nargout > 0
   h_out = h;
end

return