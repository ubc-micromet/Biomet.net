load d:\zoran\m95s164.44c
u = m95s164(:,1);
v = m95s164(:,2);
w = m95s164(:,3);
c = m95s164(:,4);
vT_s = m95s164(:,5);
vw_s = m95s164(:,6);
vq = m95s164(:,7);
[Tv,Ta,T_s,w_s,q]  = mathias(u, v, w, c, vT_s, vw_s, vq);
meansOld = mean([u,v,w,Tv,Ta,T_s,w_s,q]);
dataIN = [detrend(u) detrend(v) detrend(w) detrend(Tv) detrend(Ta) detrend(T_s) detrend(w_s) detrend(q) ];
                    %dataIN = [u v w Tv T_s w_s q];
means = mean( dataIN );
covs  = cov ( dataIN );
[means1 covs1,ce,se,ct,st,cb,sb] =rotatn1(meansOld,covs);
means1(1) = meansOld(1) * ct * ce + meansOld(2) * ct * se + meansOld(3) * st;
v_prime = meansOld(2) * ce - meansOld(1) * se;
w_prime = meansOld(3) * ct - meansOld(1) * st *ce - meansOld(2) * st * se;
means1(2) = v_prime * cb + w_prime * sb;
means1(3) = w_prime * cb - v_prime * sb;
means1(4:8) = meansOld(4:8);
disp('Means:')
disp([meansOld' means1'])
junk1 = [covs(1,1) covs(2,2) covs(3,3) covs(4,4) covs(1,2) covs(1,3) covs(2,3) covs(3,4) covs(1,4)]';
junk2 = [covs1(1,1) covs1(2,2) covs1(3,3) covs1(4,4) covs1(1,2) covs1(1,3) covs1(2,3) covs1(3,4) covs1(1,4)]';
disp( 'Covs before and after rotation' );
disp( [junk1 junk2]);
