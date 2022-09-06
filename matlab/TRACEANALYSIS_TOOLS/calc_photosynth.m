function [avg,coef] = calc_photosynth(clean_tv,gep,ppfd_absorbed)

% base on Bill's Photosynth_hw
tv_doy = convert_tv(clean_tv,'doy',6);

ppfd_absorbed_thresh = 10; %(daytime Q >= 10 umol m^-2 s^-1)
ind   	= find(ppfd_absorbed > ppfd_absorbed_thresh & ppfd_absorbed < 1650);

avg   = blockavg(ppfd_absorbed(ind),gep(ind),50,100,0);
% In the fit only use bin with more that 50 measurements
ind_avg = find(avg(:,4) > 50);

[coef, Y_hat, R2, sigma] = fitmain([0.1 30], 'fithyp1', avg(ind_avg,1), avg(ind_avg,2));
