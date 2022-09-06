function [a_ppt,numpts,ind_max] = find_cumprecip_regr(doy,ppt1,ppt2,warm_beg,warm_ed);

% compiles sets of consecutive indexes where ppt1 and ppt2 are non-NaN and fall in the warm
% season, so that a linear regression of cumulative precip can be done 
% allowing one TBRG to be calibrated against the other)

% Nick                          file created:  Jan 15, 2008
%                               Last modified: Jan 25, 2008
% Revisions:
% Jan 25, 2008
%   -changed to model 1 linear regression forced through 0 (Nick)

arg_default('warm_beg',91);
arg_default('warm_ed',304);

k=1;
i=1;
numpts = [];
while k<=length(ppt1)
    r=0;
    eval(['a.ind_reg' num2str(i) '= [];' ]);
    while ~isnan(ppt1(k+r)) & ~isnan(ppt2(k+r)) & doy(k+r)>warm_beg & doy(k+r)<warm_ed
        eval(['a.ind_reg' num2str(i) ' = [ a.ind_reg' num2str(i) '; k+r ];']);
        r=r+1;
    end
    k=k+r+1;
    if r>0
        numpts = [numpts; r];
        i=i+1;
    end
end

[y,ind_max] = max(numpts);
    
%a_ppt = eval(['linregression_orthogonal(cumsum(ppt2(a.ind_reg' num2str(ind_max) ')),cumsum(ppt1(a.ind_reg' num2str(ind_max) ')));']);
if ~isempty(ind_max)
   a_ppt = eval(['cumsum(ppt1(a.ind_reg' num2str(ind_max) '))\cumsum(ppt2(a.ind_reg' num2str(ind_max) '));']);
else
   a_ppt = 1;
end
    

disp(['=================Regression of TBRG1 on TBRG2 results=====================']);
disp(['cumTBRG1 = ' num2str(a_ppt) ' * cumTBRG2  ' ]);
disp('===========================================================================');