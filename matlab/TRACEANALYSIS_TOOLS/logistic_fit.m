function[R] = logistic_fit(PARAMETERS,Tsoil)
%This function is used to find the parameters
%for the logistic function A1,A2,A3

A1 = PARAMETERS(1);
A2 = PARAMETERS(2);
A3 = PARAMETERS(3);

R = A1./(1+exp(A2.*(A3-Tsoil)));
R=R(:);

