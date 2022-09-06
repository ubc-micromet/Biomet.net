function day = getBermsDayFromFileName(name)

day = 0;

if ~isempty(name)   
   if length(name) > 7
      str = [name(6) name(7) name(8)];
      
      day = str2num( str );
   end
end


	   