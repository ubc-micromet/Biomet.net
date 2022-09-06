%[R3,CSAT,TC,Licor1,Licor2] =pa_test;
CSAT=CSAT';
R3=R3';
cC=cov(detrend(CSAT(:,3:4)));
cT= cov(detrend([CSAT(:,3) TC(:,4)]));
rC=cov(detrend(R3(:,3:4)));
rT= cov(detrend([R3(:,3) TC(:,4)]));

disp('Sensible heat: CSAT / R3')
cC ./ rC

disp('Sensible heat: CSAT / Tc')
cC ./ cT

disp('Sensible heat: R3 / Tc')
rC ./ cT
