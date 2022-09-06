function [Matrix_Out,TransferF] = footprint_rotate(x_r,y_r,Matrix_In,alpha_rot_dgr)
% footprint_rotate - rotate a matrix of numbers
%
% Inputs
%   x_r [m,n]       -   input matrix of x coordinates
%   y_r [m,n]       -   input matrix of y coordinates
%   Matrix_In [m,n] -   input matrix to be rotated
%   alpha_rot -   angle of rotation in radians
%
% Outputs:
%   Matrix_Out1 [m2,n2] - matrix of rotated values of Matrix_in. Central
%       point of rotation is at x_r,y_r -> 0,0; Matrix has larger dimensions
%       than Matrix_In to accomodate points that "fall of the edges".  m2 and
%       n2 are calculated based on values of x_r and y_r 
%
% (c) Zoran Nesic & Bob                   File created:       Jan  4, 2007
%                                   Last modification:  Jan 16, 2007 by
%                                   Bob chen by changing plus alpha_rot_dgr
%                                   to minus alpha_rot_dgr in line 63

% Revisions:
%   
% Jan 12, 2007
%   - complete rewrite to make it completly generic.
% Jan 10, 2007
%  - changed inputs from a matrix to 3 matrices (x,y,A).  Rotated values
%  are stored in matrix B (same size as A) and matrix B1 that has 1.5 times
%  more larger dimensions in both x and y direction (taking care of the
%  points that "fall off the edges")


[n1,m1] =size(Matrix_In);
if mod(m1,2) == 0 | mod(n1,2)==0
%    error('Matrix dimensions need to be odd numbers!')
end

%find max diagonal starting from x_r=0 and y_r = 0 
% and going to max(abs(x_r)) and max(abs(y_r))
DiagMax = round(sqrt(max(abs(x_r(:)))^2+max(abs(y_r(:)))^2));

% find translation equations that move x_r and y_r into matrix
% coordinate (1:m1) and (1:n1) 

x_range = [x_r(1,1) x_r(end,end)];
Ax = (m1-1)/(x_range(2)-x_range(1));
Bx = -(m1*x_range(1)-1*x_range(2))/(x_range(2)-x_range(1));

y_range = [y_r(1,1) y_r(end,end)];
Ay = (n1-1)/(y_range(2)-y_range(1));
By = -(n1*y_range(1)-1*y_range(2))/(y_range(2)-y_range(1));

m2 = abs(round(-DiagMax*Ax + Bx)) + abs(round(DiagMax*Ax + Bx)) + 1;
x_offset =  round(x_range(1)*Ax + Bx) - round(-DiagMax*Ax + Bx);
n2 = abs(round(-DiagMax*Ay + By)) + abs(round(DiagMax*Ay + By)) + 1;
y_offset = round( y_range(1) * Ay + By) - round( DiagMax * Ay + By);

% Calculate the angle after rotation
alpha_rot_arc=alpha_rot_dgr*pi/180;

Matrix_Out = zeros(n2,m2);

alpha_in = atan2(y_r,x_r);
alpha_out = alpha_in - alpha_rot_arc;
R = sqrt(x_r.^2 + y_r.^2);
x_r_rot = R .* cos(alpha_out);
y_r_rot = R .* sin(alpha_out);

for i=1:n1
    for j=1:m1;
        try
        x_ind = x_offset + round(x_r_rot(i,j).*Ax + Bx);
        y_ind = y_offset + round(y_r_rot(i,j).*Ay + By);
        Matrix_Out(y_ind,x_ind) = Matrix_Out(y_ind,x_ind) + Matrix_In(i,j);            
%        Matrix_Out(y_ind,x_ind) = Matrix_In(i,j);
        catch
            %disp([x_ind y_ind;i j])
            %disp(' ')
        end
    end
end
TransferF.x_offset = x_offset;
TransferF.Ax = Ax;
TransferF.Bx = Bx;
TransferF.y_offset = y_offset;
TransferF.Ay = Ay;
TransferF.By = By;
