function qt = qt(dt,tf,tau,m);

ind1 = find(dt <= tf);
ind2 = find(dt > tf & dt <= tau-tf);
taudt = (tau-dt);
taudt3 = taudt .^ 3;
tautf = (tau-tf);
tautf3 = tautf ^ 3;
tfdt = (tf-dt);
tfdt3 = tfdt .^ 3;
dttf = dt ./ tf;
fn = 1 - dt./tau/2;

qt = zeros(size(dt));

qt(ind1) = m^3/tau .* [ (dttf(ind1) .^2).*(1 + tfdt(ind1) ./tautf)... 
           - 0.5 .* dttf(ind1).^2 .* (1-tfdt(ind1)./tautf)];
qt(ind2)= m^3/tau .* [ (taudt3(ind2) - taudt(ind2) .* dt(ind2).^2) ./ tautf3...   
          - 0.5 .* tau^3 .* fn(ind2)./ tautf3 ./ dttf(ind2)];
                      
