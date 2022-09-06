function traces_fcrn = get_fcrn_trace_str(varargin)

% see create_DIS_variable_name_table

traces_fcrn = [];
j = 0;
for k = 1:nargin
   for i = 1:length(varargin{k})
      if isfield(varargin{k}(i).ini,'FCRN_Variable')
         j = j+1;
         traces_fcrn(j).variableName      = varargin{k}(i).variableName ;
         traces_fcrn(j).SiteID            = varargin{k}(i).SiteID ;
         traces_fcrn(j).ini.FCRN_Variable = varargin{k}(i).ini.FCRN_Variable ;
         traces_fcrn(j).ini.FCRN_DataType = varargin{k}(i).ini.FCRN_DataType;
         traces_fcrn(j).ini.units         = varargin{k}(i).ini.units;
         traces_fcrn(j).Last_Updated      = varargin{k}(i).Last_Updated;
         traces_fcrn(j).timeVector        = varargin{k}(i).timeVector;
         traces_fcrn(j).Year              = varargin{k}(i).Year;
         traces_fcrn(j).data              = varargin{k}(i).data;
         traces_fcrn(j).inifile           = varargin{k}(i).inifile;
      end
   end
end
