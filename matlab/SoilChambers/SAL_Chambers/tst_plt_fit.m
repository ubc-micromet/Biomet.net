
timeTraceSec = (t_fit-t_fit(1))*3600;
cs = fCO2{N_optimum}.cs;
c0 = fCO2{N_optimum}.c0;
A = fCO2{N_optimum}.A;

c_exp = cs+(c0-cs)*exp(A*(timeTraceSec-(t0+timeTraceSec(optionsIn.skipPoints))));

plot(timeTraceSec,c_fit,'.',t0+timeTraceSec(optionsIn.skipPoints),c0,'r+',timeTraceSec,c_exp)