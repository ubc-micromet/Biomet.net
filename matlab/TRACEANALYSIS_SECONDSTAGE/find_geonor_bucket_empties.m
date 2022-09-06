function [ppt_tst,ind_emptied]= find_geonor_bucket_empties(doy,ppt_tst,level_drop);

% finds emptying events in the Geonor precipitation traces and removes 
% the offset

% Nick                          file created:  Jan 15, 2008
%                               Last modified: Jan 15, 2008
% revisions:

k=1;
ind_emptied = [];
while k<=length(ppt_tst)
    if ~isnan(ppt_tst(k))
        r=1;
        %while r < 3*48 & k+r <= length(ppt_tst) % bucket emptied usually begins measuring the same day
        while k+r <= length(ppt_tst)
            if isnan(ppt_tst(k+r)) 
               r=r+1;
           else
               offset=ppt_tst(k+r)-ppt_tst(k);
               break
           end
        end    
        if offset < level_drop, 
            disp(sprintf('Geonor bucket emptied on DOY %3.0f', doy(k+r)));
            ind_emptied = [ ind_emptied; k+r ];
            for m=k+r:length(ppt_tst), 
                ppt_tst(m)=ppt_tst(m)-offset; 
            end
            k=k+r-1;
        end
    end 
    k=k+1;
end