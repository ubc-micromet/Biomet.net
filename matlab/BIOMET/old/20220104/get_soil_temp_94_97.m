%
% get_soil_temp_94_97.m
%
% (c) Zoran Nesic               File created:       Nov 28, 1997
%                               Last modification:  Nov 28, 1997
%
%

% 
% Revisions:
%
pth94   = '\\boreas_005\e\data\soubc\soubc';
Tpth94  = '\\boreas_005\e\data\meaes\meaes';
pth96   = 'r:\paoa\newdata\aessoil\soil';
T1pth96  = 'r:\paoa\newdata\bonet\bnt';
T2pth96  = 'r:\paoa\newdata\aesmet\met';

t_all   = read_bor([pth94 '_dt'])-153;

% get 94 data

s2      = read_bor([pth94 '.9']);
s5      = read_bor([pth94 '.10']);
s10     = read_bor([pth94 '.11']);
s20     = read_bor([pth94 '.12']);
s50     = read_bor([pth94 '.13']);
s100    = read_bor([pth94 '.14']);
Tair    = read_bor([Tpth94 '.10']);

ind = find(floor(t_all)>=0 & floor(t_all)<=365);
t94 = t_all(ind)+1-6/24;

tmp = s2(ind);
[junk,indx] = cle_data(tmp,2,-20);
[junk,s2_94,OrigIntervals]= integz(t94(indx),tmp(indx),1:366,1);

tmp = s5(ind);
[junk,indx] = cle_data(tmp,2,-20);
[junk,s5_94,OrigIntervals]= integz(t94(indx),tmp(indx),1:366,1);

tmp = s10(ind);
[junk,indx] = cle_data(tmp,2,-20);
[junk,s10_94,OrigIntervals]= integz(t94(indx),tmp(indx),1:366,1);

tmp = s20(ind);
[junk,indx] = cle_data(tmp,2,-20);
[junk,s20_94,OrigIntervals]= integz(t94(indx),tmp(indx),1:366,1);

tmp = s50(ind);
[junk,indx] = cle_data(tmp,2,-20);
[junk,s50_94,OrigIntervals]= integz(t94(indx),tmp(indx),1:366,1);

tmp = s100(ind);
[junk,indx] = cle_data(tmp,2,-20);
[junk,s100_94,OrigIntervals]= integz(t94(indx),tmp(indx),1:366,1);

tmp = Tair(ind);
[junk,indx] = cle_data(tmp,2,-60);
[junk,Tair_94,OrigIntervals]= integz(t94(indx),tmp(indx),1:366,1);


%
% get 97 data
%


t_all   = read_bor([pth96 '_dt']);

s2      = read_bor([pth96 '.9']);
s5      = read_bor([pth96 '.10']);
s10     = read_bor([pth96 '.11']);
s20     = read_bor([pth96 '.12']);
s50     = read_bor([pth96 '.13']);
s100    = read_bor([pth96 '.14']);
Tair1    = read_bor([T1pth96 '.5']);
Tair2    = read_bor([T2pth96 '.10']);

t97 = t_all-366;
ind = find(floor(t97)>=0);
t97 = t97(ind)+1-6/24;

tmp = s2(ind);
[junk,indx] = cle_data(tmp,2,-20);
[junk,s2_97,OrigIntervals]= integz(t97(indx),tmp(indx),1:366,1);

tmp = s5(ind);
[junk,indx] = cle_data(tmp,2,-20);
[junk,s5_97,OrigIntervals]= integz(t97(indx),tmp(indx),1:366,1);

tmp = s10(ind);
[junk,indx] = cle_data(tmp,2,-20);
[junk,s10_97,OrigIntervals]= integz(t97(indx),tmp(indx),1:366,1);

tmp = s20(ind);
[junk,indx] = cle_data(tmp,2,-20);
[junk,s20_97,OrigIntervals]= integz(t97(indx),tmp(indx),1:366,1);

tmp = s50(ind);
[junk,indx] = cle_data(tmp,2,-20);
[junk,s50_97,OrigIntervals]= integz(t97(indx),tmp(indx),1:366,1);

tmp = s100(ind);
[junk,indx] = cle_data(tmp,2,-20);
[junk,s100_97,OrigIntervals]= integz(t97(indx),tmp(indx),1:366,1);

tmp = Tair1(ind);
[junk,indx] = cle_data(tmp,2,-20);
[junk,Tair1_97,OrigIntervals]= integz(t97(indx),tmp(indx),1:366,1);

tmp = Tair2(ind);
[junk,indx] = cle_data(tmp,2,-20);
[junk,Tair2_97,OrigIntervals]= integz(t97(indx),tmp(indx),1:366,1);

%
% get 96 data
%

ind = find(floor(t_all)<=366);
t96 = t_all(ind)+1-6/24;

tmp = s2(ind);
[junk,indx] = cle_data(tmp,2,-20);
[junk,s2_96,OrigIntervals]= integz(t96(indx),tmp(indx),1:366,1);

tmp = s5(ind);
[junk,indx] = cle_data(tmp,2,-20);
[junk,s5_96,OrigIntervals]= integz(t96(indx),tmp(indx),1:366,1);

tmp = s10(ind);
[junk,indx] = cle_data(tmp,2,-20);
[junk,s10_96,OrigIntervals]= integz(t96(indx),tmp(indx),1:366,1);

tmp = s20(ind);
[junk,indx] = cle_data(tmp,2,-20);
[junk,s20_96,OrigIntervals]= integz(t96(indx),tmp(indx),1:366,1);

tmp = s50(ind);
[junk,indx] = cle_data(tmp,2,-20);
[junk,s50_96,OrigIntervals]= integz(t96(indx),tmp(indx),1:366,1);

tmp = s100(ind);
[junk,indx] = cle_data(tmp,2,-20);
[junk,s100_96,OrigIntervals]= integz(t96(indx),tmp(indx),1:366,1);

tmp = Tair1(ind);
[junk,indx] = cle_data(tmp,2,-20);
[junk,Tair1_96,OrigIntervals]= integz(t96(indx),tmp(indx),1:366,1);

tmp = Tair2(ind);
[junk,indx] = cle_data(tmp,2,-20);
[junk,Tair2_96,OrigIntervals]= integz(t96(indx),tmp(indx),1:366,1);

tmp = [Tair_94' s2_94' s5_94' s10_94' s20_94' s50_94' s100_94'];
save c:\cd-rom\soil_94 tmp -ascii

tmp = [Tair1_96' Tair2_96' s2_96' s5_96' s10_96' s20_96' s50_96' s100_96'];
save c:\cd-rom\soil_96 tmp -ascii

tmp = [Tair1_97' Tair2_97' s2_97' s5_97' s10_97' s20_97' s50_97' s100_97'];
save c:\cd-rom\soil_97 tmp -ascii

