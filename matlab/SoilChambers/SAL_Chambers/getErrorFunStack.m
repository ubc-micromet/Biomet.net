function callerStack = getErrorFunStack()
    strStack = dbstack;
    callerStack = [];
    for countI = 2:length(strStack)
        callerStack = [strStack(countI).name ':' callerStack ]; %#ok<*AGROW>
    end
    