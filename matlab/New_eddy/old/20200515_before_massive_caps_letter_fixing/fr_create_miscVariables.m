function miscVariables = fr_create_miscVariables(configIn,Instrument_data);

%Revisions: Oct 12, 2002 - Fixed bug that overwrote miscVariables for each loop

miscVariables = [];
for currentVariable = 1:length(configIn.MiscVariables)              % cycle for each variable 
    for i = 1:length(configIn.MiscVariables(currentVariable).Execute)
        eval(char(configIn.MiscVariables(currentVariable).Execute(i)));
    end
    
    miscVariables = setfield(miscVariables,configIn.MiscVariables(currentVariable).Name,miscVar);
end % for 

