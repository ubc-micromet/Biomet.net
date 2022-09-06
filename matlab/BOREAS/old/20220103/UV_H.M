%
% Checking the influence of u'v' on H
%
%
% (c) Zoran Nesic				File created:		Oct 24, 1996
%								Last modification:  Oct 24, 1996
%
t = read_bor('h:\zoran\bor96\bor96_dt')-0.25;
uv = read_bor('h:\zoran\bor96\bor96_26.2_2');
h = read_bor('h:\zoran\bor96\bor96_81.2_2');
plot(t,abs(uv),t,(h-mean(h))/1000-0.5);grid;zoom on
axis([260 280 -1 .5])
fid = fopen('h:\zoran\bor96\uv_H.tst','w');
for i=140:290;
	ind = find( floor(t) == i );
	s = max(abs(uv(ind)));
	if s < .4,
		fprintf('%d %f\n',[i s]);
		fprintf(fid,'%d %f\n',[i s]);
	end;
end,
fclose(fid);

