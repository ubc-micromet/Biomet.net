% file: roth_ini.m
%
%  Main file that tests the calculation procedure (conversion to
%  engineering units, detrending, coordinate rotation, corrections...)
%
%
% (c) Zoran Nesic & Matthias Roth       File created:       Oct   , 1996
%                                       Last modification:  Nov  2, 1996
%

% load raw data

load d:\zoran\m95s164.44c

% get the voltages/wind speeds

u = m95s164(:,1);
v = m95s164(:,2);
w = m95s164(:,3);
c = m95s164(:,4);
vT_s = m95s164(:,5);
vw_s = m95s164(:,6);
vq = m95s164(:,7);

% delete the input matrix

clear m95s164

% Convert voltages to engineering units

[Tv,Ta,T_s,w_s,q]  = mathias(u, v, w, c, vT_s, vw_s, vq);

% do detrending and coordinate rotation

[meansOld, covs,means1, covs1, DetrendData] = rotatn2([u,v,w,Tv,Ta,T_s,w_s,q],1);

% print results for comparison

disp('Means:')
disp([meansOld' means1'])
junk1 = [covs(1,1) covs(2,2) covs(3,3) covs(4,4) covs(1,2) covs(1,3) covs(2,3) covs(3,4) covs(1,4)]';
junk2 = [covs1(1,1) covs1(2,2) covs1(3,3) covs1(4,4) covs1(1,2) covs1(1,3) covs1(2,3) covs1(3,4) covs1(1,4)]';
disp( 'Covs before and after rotation' );
disp( [junk1 junk2]);

Pbarometric = 101490;

SOUNDV = corr_H(Pbarometric, meansOld(4), 26.9, covs1(1,3), covs1(3,4), covs1(3,6), covs1(7,8))
%SOUNDV = corr_H(Pbarometric, meansOld(4), 26.9)
