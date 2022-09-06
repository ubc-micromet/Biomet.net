function [x_mat,doy,t_mat] = reshape_year(t,x,start_doy)
% [x_mat,doy,t_mat] = reshape_year(t,x) Reshape so years are in columns
%
% [x_mat,doy,t_mat] = reshape_year(t,x,start_doy) Reshape so years beginning at
%    start_doy are in columns

arg_default('start_doy',1);

% Find no of years
yy_vec = datevec(t);
yy = unique(yy_vec(:,1));
n_y = length(yy);

doy = fr_round_hhour(1+1/48:1/48:367);
t = fr_round_hhour(t);
t_doy = fr_round_hhour(t-datenum(yy_vec(:,1),1,0));

for i = 1:n_y
    ind_y = find(t > datenum(yy(i),1,start_doy,0,29,0) & t < datenum(yy(i)+1,1,start_doy,0,1,0));
    
    if length(ind_y>1)
        if ~exist('k')
            k = 1;
        end
        t_mat(:,k) = fr_round_hhour([datenum(yy(i),1,1,0,30,0):1/48:datenum(yy(i),1,367)]');
        x_mat(:,k) = NaN.*ones(366*48,1);
        x_mat(ind_y-ind_y(1)+1,k) = x(ind_y);
        k = k+1;
    end
end

