function vwc_interp = interp_vwc(tv,vwc)

ind_nan    = find( isnan(vwc));
ind_notnan = find(~isnan(vwc));

if length(ind_nan) ~= length(vwc)
    vwc_interp = interp1(tv(ind_notnan),vwc(ind_notnan),tv);
else
    vwc_interp = vwc;
end

return