function y = fr_dispike(x,threshold)

diff1 = diff(x);                        ;find differences
sigma = std(diff1);                     ;find total STD of differences
ind1 = find(abs(diff1)>= threshold * sigma); find indexes of all diff. that exceed threshold * STD
ind2 = find(diff(ind1) == 1);           ; find indexes of all consecutive diff1 that esceed the treshold

