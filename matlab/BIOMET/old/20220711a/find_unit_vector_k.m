function [b,k] = find_unit_vector_k(U)
% [b,k] = find_unit_vector_k(U)
%
% Find the tilt coefficients b0, b1, and b2 by solving eq.(48)
% in Wilczak et al (2001). The code for this function was given in
% that paper.
% Then eq. (42) in the paper is evaluated and the result returned in 
% the unit vector k, which, following the interpreation by Xuhui Lee
% is parallel to the new z axis
%
% U = [u v w] measured, b = [b0 b1 b2], k - unit vector parallel to 
% the new coordinate z axis

u=U(:,1); 
v=U(:,2); 
w=U(:,3); 

flen=length(u); 
su=sum(u); sv=sum(v); sw=sum(w); 				%sums of velocities 
suv=sum(u.*v); suw=sum(u.*w); svw=sum(v.*w); %sums of velocity products 
su2=sum(u.*u); sv2=sum(v.*v); 

H=[flen su sv; su su2 suv; sv suv sv2];%create 3 x 3 matrix 
g=[sw suw svw]'; 								%transpose of g 
b=H\g; 											%matrix left division 

% Be careful here - b(1) = b_0 in Wilczak!!!!
% Eq.(42)
k(1) = -b(2)/sqrt(b(2)^2+b(3)^2+1);
k(2) = -b(3)/sqrt(b(2)^2+b(3)^2+1);
k(3) =     1/sqrt(b(2)^2+b(3)^2+1);
