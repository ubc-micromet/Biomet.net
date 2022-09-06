function [Tair_a] = fr_Tair_Chi_Iteration(H_density, Tair_C, Pbarometric)
%
% This little function tries to bootstrap the calculation procedure for 
% conversion of sonic temperature (Tair_c in degC) from virtual to absolute
% (Tair_a).  It's bootstrapping because we use an open path sensor to get
% the chi and chi already needs the absolute temperature

%	Inputs:   H_density = water vapour density; mmol/m3
%	          Tair_C = sonic virtual temperature; degC
%            Pbarometric = Barometric pressure; kPa
%  Outputs:  Tair_a = actual air temperature; degC

% Revisions: May 26, 2003 - Fixed chi calculation which was mistakenly assuming H_density in mmol/m3 was equiv. to Ma  
%                      Note that this meant that chi_calc = chi_actual./0.622 at all times.  
%                      And fixed Tair calculation to use T in Kelvins rather than deg C.
%
%           Sept 23, 2003 - Fixed Tair calculation which had chi (g h2o /g air) erroneously divided by 1000.  I've now moved to Kai's
%                     formulas with mole fraction rather than specific humidity

UBC_biomet_constants;

Tair_C     = Tair_C+ZeroK; %convert to Kelvins

%convert from number density to mole fraction
chi      = H_density.*R.*Tair_C./(Pbarometric.*1000); %(mmol h2o/m3 air * J/mol/K * K ) /Pa = mmol h2o/mol wet air
Tair_a   = Tair_C ./ (1 + 0.32 .* chi./1000);

chi      = H_density.*R.*Tair_a./(Pbarometric.*1000);
Tair_a   = Tair_C ./ (1 + 0.32 .* chi ./ 1000);

chi      = H_density.*R.*Tair_a./(Pbarometric.*1000);
Tair_a   = Tair_C ./ (1 + 0.32 .* chi ./ 1000);

chi      = H_density.*R.*Tair_a./(Pbarometric.*1000);
Tair_a   = Tair_C ./ (1 + 0.32 .* chi ./ 1000);

%convert back to degree C
Tair_a   = Tair_a - ZeroK;




%----------------------------------------------------------------------------------
%OLD AND MISTAKEN!!!!!!!!!!!!!!
%convert from number density to mass density
%H_density = H_density.*Mw./1000; %g/m3
%Tair_C     = Tair_C+ZeroK; %convert to Kelvins


%chi      = (H_density.*R.*Tair_C./Ma)./(Pbarometric.*1000); %(g h2o/m3 air * J/mol/K * K * mol/g air) /Pa
%Tair_a   = Tair_C ./ (1 + 0.51 .* chi ./ 1000);

%chi      = (H_density.*R.*Tair_a./Ma)./(Pbarometric.*1000);
%Tair_a   = Tair_C ./ (1 + 0.51 .* chi ./ 1000);

%chi      = (H_density.*R.*Tair_a./Ma)./(Pbarometric.*1000);
%Tair_a   = Tair_C ./ (1 + 0.51 .* chi ./ 1000);

%chi      = (H_density.*R.*Tair_a./Ma)./(Pbarometric.*1000);
%Tair_a   = Tair_C ./ (1 + 0.51 .* chi ./ 1000);

%convert back to degree C
%Tair_a   = Tair_a - ZeroK;