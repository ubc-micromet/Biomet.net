function x=inf_loop

lasterr('')
try
    for i=1:1e38
        x = sin(i);
    if i == 100
        x = [1 2] * [1 2 3];
    end
    end
catch
    disp('Before');
    lasterr;
end