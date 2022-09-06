function [y,sp_len,sp_ind,Md,MAD]= fr_despike(x,window_len,threshold,threshold_const)
% fr_despike - despiking of data
%
% Inputs:
%   x               - input data vector
%   window_len      - size of window to use (13*48=624)
%   threshold       - threshold (4)
%
% Outputs:
%   y               - 
%   sp_len          - 
%   sp_ind          -
%   Md              -
%   MAD             -
%
% Notes:
%   - not very good in catching the leading or lagging spikes (first or
%   last point). The difference calculation creates more NaNs where NaNs
%   are present in the intial trace. NaNs are already associated with times
%   of instrument failure and poor mixing (after ustar filter) but are
%   missed in the despiking. fr_fill_and_despike.m adopts a technique using
%   half hourly ensemble averaging to fill the raw trace before despiking
%   and then remove the filled points after, thus maximising the number of
%   spikes caught.During periods when spikes are more prevelant the Median 
%   Average Deviation (the basis of the despiking technique, Papale et al., 2008) 
%   will be large and a limited number of values may be
%   accepted which the user may still feels are spikes.
%
% Last Modification: Nov 10, 2009 (Nick)
%
% Revisions:
%  Nov 10, 2009 (Nick)
%     -added a work around for MATLAB6 for years with incomplete datasets   
%  Dec 4, 2007 (Zoran)
%     - changed the order of the input parameters to better match the
%     legacy code
%     - fixed up the output sp_ind
%     - despiked x and stored results into y
%
%Modified Nov 27 07 Iain Hawthorne
%different despiking technique from that already in the FCRN function library and as outlined
%in publication by Papale et al 06, "Algorithms and uncertainty processing eddy covariance". 
%The outlier detection is based on the double-difference time series, using the median of absolute
%deviatation about the median (MAD) as a robust outlier estimator (Sachs, 1996).
%
% The function maintains compatibility with the old fr_despike function.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%This first 'if' statement initiates the new Papale algorithm 'if' there
%are 3 input arguments.
y=x;                 % make output trace = input trace
if nargin == 3
    %as outlined in Papale et al 2006
    %calculate (d) diff(i) = (x(i)-x(i-1))-(x(i+1)-x(i)
    traceIndiff = diff(x);
    N = length(traceIndiff);
    d = -diff(traceIndiff);
    %window_len = 48*13; now set as an input parameter
    nPeriods = floor(N/window_len); 
    sp_ind = zeros(size(d));

    Md = zeros(floor(N/window_len),1);
    MAD = zeros(size(Md));
    for i = 1:nPeriods
        kk = (i-1)*window_len;
        jj = kk+1:kk+window_len;
        ind= find(~isnan(d(jj)));
        try
            Md(i) = median(d(jj(ind)));
        catch
            Md(i) = NaN;
        end
        % patch needed for Matlab 6; Nick, Nov 10, 2009
        %MAD(i) = median(abs(d(jj(ind))-Md(i)));
        %
        if ~isempty(ind)
            MAD(i) = median(abs(d(jj(ind))-Md(i)));
        else
            MAD(i) = NaN;
        end
        sp_ind(jj) = ( d(jj) < ( Md(i) - threshold * MAD(i)/0.6745 ) ) ...
                      | ( d(jj) > ( Md(i) + threshold * MAD(i)/0.6745 ) );
    end
    jj = nPeriods*window_len+1:length(d);
    sp_ind(jj) = ( d(jj) < ( Md(nPeriods) - threshold * MAD(nPeriods)/0.6745 ) ) ...
                  | ( d(jj) > ( Md(nPeriods) + threshold * MAD(nPeriods)/0.6745 ) );
%    sp_ind = [0 ; sp_ind ; 0];
    sp_ind = [0 ; sp_ind ; 0];
    good_ind = find(sp_ind==0);
    sp_ind = find(sp_ind==1);
    y(sp_ind) = NaN;
    sp_len = length( find(sp_ind) );
else        
    % the legacy version of the fr_dispike program
    disp('You are using the old syntax for fr_despike.')
    disp('Please check the fr_despike for the new syntax and new algorithm.');
    % Create dummy outputs to match the new version above
    Md = [];MAD=[];
    % rename the input parameters
    spike_len = window_len;
	sp_ind = fr_find_spike(x,spike_len,threshold,threshold_const);
	y = x;
	if ~isempty(sp_ind)
        N = length(y);
        ind = 1:N;
        cl_ind = ind;
        cl_ind(sp_ind) = [];
        if spike_len > 1
            % next two lines work but slow (for 1 point spikes
            interp_points = interp1(ind(cl_ind),y(cl_ind),sp_ind);
            y(sp_ind) = interp_points;
        else
            sp_ind1 = sp_ind;
            if sp_ind(1) == 1
                sp_ind1 = [sp_ind(2:end)];
            end
            if sp_ind(end) == N
               sp_ind1 = sp_ind(1:end-1); 
            end
            y(sp_ind1) = (y(sp_ind1-1)+y(sp_ind1+1))/2;
            if sp_ind(1) == 1
                y(1) = y(2);
            end
            if sp_ind(end) == N
               y(end) = y(end-1); 
            end
        end
        sp_len = length(sp_ind);
	else
        sp_len = [];
        sp_ind = [];
	end

end