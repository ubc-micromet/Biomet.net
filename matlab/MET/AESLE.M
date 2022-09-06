function cal_aes_le = aesle(time, le, e);
%*****************************************************************%
% THIS MATLAB FUNCTION RECALCULATES THE AES LATENT HEAT FLUX      %
% BASED ON EQUATIONS PROVIDED IN HAROLD'S E-MAIL (AUG 3 1995)     %                                              %
%                                                                 %
%        cal_aes_le = aesle(time,le, e)                           %
%                                                                 %
%        time = column containing decimal time                    %
%        le = aes latent heat flux prior to recalculation (W m-2) %
%        e = vapour pressure (kPa)                                %
%                                                                 %
%*****************************************************************%        

ind = find(time < 153);
cal_aes_le(ind) = le(ind).*0.843;

ind = find(time >= 153);
cal_aes_le(ind) = le(ind).*(0.9527 + 0.2888.*e(ind));



