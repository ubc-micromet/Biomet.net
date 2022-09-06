function [Fc,Le,H,means,eta,theta,beta] = ugly_loop(Stats)

L = length(Stats);
Fc = NaN * zeros(L,1);
Le = NaN * zeros(L,1);
H = NaN * zeros(L,1);
eta = NaN * zeros(L,1);
theta = NaN * zeros(L,1);
beta = NaN * zeros(L,1);

for i = 1:L
    try
        Fc(i) = Stats(i).Fluxes.LinDtr.AfterRot(5);
        Le(i) = Stats(i).Fluxes.LinDtr.AfterRot(1);
        H(i) = Stats(i).Fluxes.LinDtr.AfterRot(2);
        eta(i) = Stats(i).Angles.LinDtr(1);
        theta(i) = Stats(i).Angles.LinDtr(2);
        beta(i) = Stats(i).Angles.LinDtr(3);
        means(i,:) = Stats(i).AfterRot.AvgMinMax(1,:);
    end
end