function x=plotsn(in,points,shiftup)

[Px,F] = spectrum(in,points,[],[],20.83);
%loglog(F,Px(:,1),[.001 100],[100*shiftup 100*shiftup*10^(-25/3)])
semilogx( F, F.*Px(:,1))   %
varx = mean(Px(:,1));      %
varx/std(in)^2
