ind=[35 37 41 52 55 81 82 88 94];
N = length(ind);
[ds,t,H,LE] = extr_bor(ind(1));
ddd = ds;
sss = [t,H,LE];
for i=ind(2:N)
	[ds,t,H,LE] = extr_bor(i);
	sss = [sss ; [t,H,LE]];
	ddd = [ddd ;ds];
end
save weber01.txt sss -ascii

fid = fopen('weber01d.txt','w');

for i=1:N
    fprintf(fid,'%d    %s\r\n',ind(i),ddd(i,:));
end
fclose(fid)
