function LE_filled = fr_fill_LE_from_reg_LE_Rn(Net_R,Pot_rad,LE,window)
% LE_filled = fr_fill_LE_from_reg_LE_Rn(Net_R,Pot_rad,LE,window)
%
% Filling LE from a regression of LE against Net_R. The regression is done
% for moving window of width window observations (default 10*48, i.e. ten
% days) Praveena, May, 2005
 
arg_default('window', 10*48);

 LE_modelled = NaN.*ones(size(LE));
 
 for i=[1:window:length(LE)-window-1 length(LE)-window-1]
     i2=i+window;
     LE1=LE(i:i2);
     NET1=Net_R(i:i2);
     potr= Pot_rad(i:i2);
     isday=find(potr>0.);
     [a,sig_a,r,y_cl95] = linreg(NET1(isday),LE1(isday));
      newLe=a(2)+a(1).*NET1;
     newLe(find(potr==0.))=0;
     LE_modelled(i:i2) = newLe;
 end

 ind_nan = find(isnan(LE));
 disp(['Number of LE before filling: ' num2str(length(ind_nan))]);

 LE_filled = LE;
 LE_filled(ind_nan) = LE_modelled(ind_nan);
 
 ind_nan = find(isnan(LE_filled));
 disp(['Number of LE still missing: ' num2str(length(ind_nan))]);
 
 LE_filled(ind_nan) = 0;