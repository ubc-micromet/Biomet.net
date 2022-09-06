function [indX,indY] = db_fit_in(x,y)

    if y(1)> x(end) | y(end)<x(1)
        error 'Ranges do not overlap'
    end 
    X1 = find(y(1)==x);
    if ~isempty(X1)
        Y1 = 1;
    else
        Y1 = find(x(1)==y);
        Y1 = Y1(1);
        X1 = 1;
    end
    XN = find(y(end)==x);
    if ~isempty(XN)
        YN = length(y);
    else
        YN = find(x(end)==y);
        YN = YN(end);
        XN = length(x);
    end
    indX = X1:XN;
    indY = Y1:YN;    
