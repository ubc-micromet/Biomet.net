function [stat, angle, e] = regresslms_sub (x, y, angle0, angle1, n_angle)
%
stat = zeros (4,1);
da = (angle1 - angle0) / (n_angle - 1);
slp = zeros(n_angle, 1);
icept = zeros(size(slp));
angle = zeros(size(slp));
e = zeros(size(slp));

for i = 0 : n_angle-1
	j = i + 1;
	angle(j) = angle0 + i * da;
	slp(j) = tan (angle(j) * pi / 180.0);
	z = y - slp(j) * x;
	icept(j) = lms (z);
	e(j) = median ((z - icept(j)) .^ 2);
end
i = min(find (e == min (e)));
stat(1) = slp(i);
stat(2) = icept(i);
stat(3) = e(i);
