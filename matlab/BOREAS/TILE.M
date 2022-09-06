function x = tile;

h = get(0,'children');
n = length(h);
h = sort(h);
if n > 0
    a = [   4 386 504 324
          517 386 504 324
            4   4 504 324
          517   4 504 324]; 
    for i=1:n
        set(h(i),'position',a(i,:));
        figure(h(i));
    end
end

    
