function Stats_New = xsite_flux(DateIn)
[Stats_New,HF_Data] = yf_calc_module_main(DateIn,'XSITE');

dataX = [ Stats_New.MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs   Stats_New.SecondEddy.Three_Rotations.AvgDtr.Fluxes.Hs ...
          Stats_New.MainEddy.Three_Rotations.AvgDtr.Fluxes.LE_L Stats_New.SecondEddy.Three_Rotations.AvgDtr.Fluxes.LE_L ...
          Stats_New.MainEddy.Three_Rotations.AvgDtr.Fluxes.Fc   Stats_New.SecondEddy.Three_Rotations.AvgDtr.Fluxes.Fc ...
      ];
disp('       LI-7000  LI-7500');
disp(sprintf('Hs =    %6.2f  %6.2f \nLE =    %6.2f  %6.2f \nFc =    %6.2f  %6.2f \n',dataX));
disp(sprintf('Pair = %f',Stats_New.MiscVariables.BarometricP))
disp(sprintf('Tair = %f',Stats_New.MiscVariables.Tair))

disp(Stats_New.MainEddy.Three_Rotations.Avg)
disp(Stats_New.MainEddy.Three_Rotations.Std)
disp('')
disp(Stats_New.SecondEddy.Three_Rotations.Avg)
disp(Stats_New.SecondEddy.Three_Rotations.Std)
