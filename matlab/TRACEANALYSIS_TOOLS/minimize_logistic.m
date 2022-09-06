function[ESS]=minimize_logistic(PARAMETERS,Tsoil,OBS)

R = logistic_fit(PARAMETERS,Tsoil);
ESS = sum((OBS-R).^2);




