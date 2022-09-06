counter=0;
for i=1:NumOfLines
	if NumInt(i,1) == -10000
		counter=counter+1;
		if (NumInt(i-1,1) ~= -10000) & (NumInt(i+1,1) ~= -10000)
			%
			% Recalculate the first four channels only
			%
			for j=1:4
				NumInt(i,j) = (NumInt(i-1,j) + NumInt(i+1,j))*.5;
			end
		else
			'>>>>> More than one consecutive error'
		end
	end
end
counter

