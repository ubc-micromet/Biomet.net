function index = locateBermsVariableIndex( bermsVariables, variableName )

index = 0;    %default index if the variable was not found within the vector
done = 0;     %done flag, signaling if the varaible was found or not found in the entire vector
countVar = 1; %counts each variable in bermsVariables

while ~done
   
   %if the variable is found then set the index and set the done flag
   if strcmp(bermsVariables(countVar),variableName)
      index = countVar;
      done = 1;
   end
   
   %increment to the next variable
   countVar = countVar+1;
   
   %if the end of the bermsVariables was reached then finish (set the done flag)
   if countVar > length(bermsVariables)
      done = 1;
      index = 0;
   end
end
      