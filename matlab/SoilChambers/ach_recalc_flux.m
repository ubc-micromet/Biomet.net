function [fluxNew] = ach_recalc_flux(evOri,evNew,flux);

fluxNew = flux;

fluxNew = fluxNew./evOri;
fluxNew = fluxNew.*evNew;

