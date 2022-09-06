    
try
    fprintf('Started: %s\n',mfilename);
    
    % Run UBC_Totem cleaning
    dateVecNow = datevec(floor(now));
    yearNow = dateVecNow(1);
    % clean last and the current year
    fr_automated_cleaning(yearNow-1:yearNow,'UBC_Totem',[1 2 3 ]);
    %exit;
catch
    fprintf('*** Error in: %s ***\n',mfilename);
end
fprintf('Finished: %s\n',mfilename);    
