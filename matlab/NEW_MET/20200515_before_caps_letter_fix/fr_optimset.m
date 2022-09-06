function options = fr_optimset(varargin)
%FR_OPTIMSET Create/alter OPTIM OPTIONS structure including fit method.
%   OPTIONS = FR_OPTIMSET('PARAM1',VALUE1,'PARAM2',VALUE2,...) creates an
%   optimization options structure OPTIONS in which the named parameters have
%   the specified values.  Any unspecified parameters are set to [] (parameters
%   with value [] indicate to use the default value for that parameter when OPTIONS 
%   is passed to the optimization function). It is sufficient to type only the 
%   leading characters that uniquely identify the parameter.  Case is ignored for 
%   parameter names.  
%   NOTE: For values that are strings, correct case and the complete string are required;
%   if an invalid string is provided, the default is used.
%   
%   OPTIONS = FR_OPTIMSET(OLDOPTS,'PARAM1',VALUE1,...) creates a copy of OLDOPTS with
%   the named parameters altered with the specified values.
%   
%   OPTIONS = FR_OPTIMSET(OLDOPTS,NEWOPTS) combines an existing options structure
%   OLDOPTS with a new options structure NEWOPTS.  Any parameters in NEWOPTS
%   with non-empty values overwrite the corresponding old parameters in OLDOPTS. 
%   
%   FR_OPTIMSET with no input arguments and no output arguments displays all 
%   parameter names and their possible values.
%
%   OPTIONS = FR_OPTIMSET (with no input arguments) creates an options structure
%   OPTIONS where all the fields are set to [].
%
%   OPTIONS = FR_OPTIMSET(OPTIMFUNCTION) creates an options structure with all
%   the parameter names and default values relevant to the optimization
%   function named in OPTIMFUNCTION. For example,
%           fr_optimset('fminbnd') 
%   returns an options structure containing all the parameter names and default 
%   values relevant to the function 'fminbnd'.
%   
%FR_OPTIMSET PARAMETERS
%DerivativeCheck - Compare user supplied derivatives (gradients or Jacobian)
%                  to finite-differencing derivatives  [ on | {off}]
%Diagnostics - Print diagnostic information about the function to be minimized
%              or solved [ on | {off}]
%DiffMaxChange - Maximum change in variables for finite difference gradients
%              [ positive scalar  | {1e-1} ]
%DiffMinChange - Minimum change in variables for finite difference gradients
%              [ positive scalar  | {1e-8} ]
%Display - Level of display [ off | iter | {final} ]  
%GoalsExactAchieve - Number of goals to achieve exactly (do not over- or
%                    under-achieve) [ positive scalar integer | {0}]
%GradConstr - Gradients for the nonlinear constraints defined by user
%                    [ on | {off} ]
%GradObj - Gradient(s) for the objective function(s) defined by user
%                    [ on | {off}]
%Hessian - Hessian for the objective function defined by user  [ on | {off} ]
%HessPattern - Sparsity pattern of the Hessian for finite-differencing
%              [ sparse matrix ]
%HessUpdate - Quasi-Newton updating scheme 
%             [ {bfgs} | dfp | gillmurray | steepdesc ] 
%Jacobian - Jacobian for the objective function defined by user
%JacobPattern - Sparsity pattern of the Jacobian for finite-differencing
%               [ sparse matrix ]
%LargeScale - Use large-scale algorithm if possible [ {on} | off ]
%LevenbergMarquardt - Chooses Levenberg-Marquardt over Gauss-Newton algorithm
%                     [ on | off]
%LineSearchType - Line search algorithm choice [ cubicpoly | {quadcubic} ]
%MaxFunEvals - Maximum number of function evaluations allowed 
%                   [ positive integer ]
%MaxIter - Maximum number of iterations allowed [ positive integer ]
%MaxPCGIter - Maximum number of PCG iterations allowed [positive integer]
%MeritFunction - Use goal attainment/minimax merit function [ {multiobj} | singleobj ]
%Method - Method used in function fit [ {OLS} | MAD | CACHY ]
%MinAbsMax - Number of F(x) to minimize the worst case absolute values
%                   [ positive scalar integer | {0} ]
%PrecondBandWidth - Upper bandwidth of preconditioner for PCG 
%                    [ positive integer | Inf | {0} ]
%TolCon - Termination tolerance on the constraint violation [ positive scalar ]
%TolFun - Termination tolerance on the function value [ positive scalar ]
%TolPCG - Termination tolerance on the PCG iteration 
%         [ positive scalar | {0.1} ]
%TolX - Termination tolerance on X [ positive scalar ]
%TypicalX - Typical X values [ vector ]
%
%   See also OPTIMGET, FZERO, FMINBND, FMINSEARCH.

% Future options (to be implemented):
%
%ActiveConstrTol - The tolerance used to determine which constraints are
%                  active for the interior-point methods at algorithm 
%                  end [ positive scalar ]
%HessMult - Alternative Hessian multiplication function [ string ]
%JacobMult - Alternative Jacobian multiplication function [ string ]
%OutputFcn - Name of installable output function  [ string ]
%   This output function is called by the solver after each time step.  When
%   a solver is called with no output arguments, OutputFcn defaults to
%   'optimplot'.  Otherwise, OutputFcn defaults to ''
%Preconditioner - Alternative preconditioning function for PCG [ string ] 
%ShowStatusWindow - Show window of performance statistics
  
%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision: 1.14 $  $Date: 1998/08/17 19:31:59 $

% Print out possible values of properties.
if (nargin == 0) & (nargout == 0)
   fprintf('        DerivativeCheck: [ on | {off} ]\n');
   fprintf('            Diagnostics: [ on | {off} ]\n');
   fprintf('          DiffMaxChange: [ positive scalar {1e-1} ]\n');
   fprintf('          DiffMinChange: [ positive scalar {1e-8} ]\n');
   fprintf('                Display: [ off | iter | {final} ]\n');
   fprintf('      GoalsExactAchieve: [ positive scalar | {0} ]\n');
   fprintf('             GradConstr: [ on | {off} ]\n');
   fprintf('                GradObj: [ on | {off} ]\n');
   fprintf('                Hessian: [ on | {off} ]\n');
   fprintf('            HessPattern: [ sparse matrix ]\n');
   fprintf('             HessUpdate: [ dfp | gillmurray | steepdesc | {bfgs} ]\n');
   fprintf('           JacobPattern: [ sparse matrix ]\n');
   fprintf('               Jacobian: [ on | {off} ]\n');
   fprintf('             LargeScale: [ {on} | off ]\n');
   fprintf('     LevenbergMarquardt: [ on | off ]\n');
   fprintf('         LineSearchType: [ cubicpoly | {quadcubic} ]\n');
   fprintf('            MaxFunEvals: [ positive scalar ]\n');
   fprintf('                MaxIter: [ positive scalar ]\n');
   fprintf('             MaxPCGIter: [ positive scalar ]\n');
   fprintf('          MeritFunction: [ singleobj | multiobj ]\n');
   fprintf('                 Method: [ {OLS} | MAD | CACHY ]\n');
   fprintf('              MinAbsMax: [ positive scalar | {0} ]\n');
   fprintf('       PrecondBandWidth: [ positive scalar | Inf ]\n');
   fprintf('                 TolCon: [ positive scalar ]\n');
   fprintf('                 TolFun: [ positive scalar ]\n');
   fprintf('                 TolPCG: [ positive scalar ]\n');
   fprintf('                   TolX: [ positive scalar ]\n')
   fprintf('               TypicalX: [ vector ]\n');
   fprintf('\n');
   return;
end

% If we pass in a function name then pass return the defaults.
if (nargin==1) & ischar(varargin{1})
   funcname = lower(varargin{1});  
   if ~exist(funcname)
      msg = sprintf(...
         'No default options available: the function ''%s'' does not exist on the path.',funcname);
      error(msg)
   end
   try 
      options = feval(funcname,'defaults');
   catch
      msg = sprintf(...
         'No default options available for the function ''%s''.',funcname);
      error(msg)
   end
   return
end


Names = [
   'ActiveConstrTol   '
   'DerivativeCheck   '
   'Diagnostics       '
   'DiffMaxChange     '
   'DiffMinChange     '
   'Display           '
   'GoalsExactAchieve '
   'GradConstr        '
   'GradObj           '
   'Hessian           '
   'HessMult          '
   'HessPattern       '
   'HessUpdate        '
   'Jacobian          '
   'JacobMult         '
   'JacobPattern      '
   'LargeScale        '
   'LevenbergMarquardt'
   'LineSearchType    '
   'MaxFunEvals       '
   'MaxIter           '
   'MaxPCGIter        '
   'MeritFunction     '
   'Method            '
   'MinAbsMax         '
   'Preconditioner    '
   'PrecondBandWidth  '
   'ShowStatusWindow  '
   'TolCon            '
   'TolFun            '
   'TolPCG            '
   'TolX              '
   'TypicalX          '
];
[m,n] = size(Names);
names = lower(Names);

% Combine all leading options structures o1, o2, ... in FR_OPTIMSET(o1,o2,...).
options = [];
for j = 1:m
   eval(['options.' Names(j,:) '= [];']);
end
i = 1;
while i <= nargin
   arg = varargin{i};
   if isstr(arg)                         % arg is an option name
      break;
   end
   if ~isempty(arg)                      % [] is a valid options argument
      if ~isa(arg,'struct')
         error(sprintf(['Expected argument %d to be a string parameter name ' ...
               'or an options structure\ncreated with FR_OPTIMSET.'], i));
      end
      for j = 1:m
         if any(strcmp(fieldnames(arg),deblank(Names(j,:))))
            eval(['val = arg.' Names(j,:) ';']);
         else
            val = [];
         end
         if ~isempty(val)
            eval(['options.' Names(j,:) '= val;']);
         end
      end
   end
   i = i + 1;
end

% A finite state machine to parse name-value pairs.
if rem(nargin-i+1,2) ~= 0
   error('Arguments must occur in name-value pairs.');
end
expectval = 0;                          % start expecting a name, not a value
while i <= nargin
   arg = varargin{i};
   
   if ~expectval
      if ~isstr(arg)
         error(sprintf('Expected argument %d to be a string parameter name.', i));
      end
      
      lowArg = lower(arg);
      j = strmatch(lowArg,names);
      if isempty(j)                       % if no matches
         error(sprintf('Unrecognized parameter name ''%s''.', arg));
      elseif length(j) > 1                % if more than one match
         % Check for any exact matches (in case any names are subsets of others)
         k = strmatch(lowArg,names,'exact');
         if length(k) == 1
            j = k;
         else
            msg = sprintf('Ambiguous parameter name ''%s'' ', arg);
            msg = [msg '(' deblank(Names(j(1),:))];
            for k = j(2:length(j))'
               msg = [msg ', ' deblank(Names(k,:))];
            end
            msg = sprintf('%s).', msg);
            error(msg);
         end
      end
      expectval = 1;                      % we expect a value next
      
   else
      eval(['options.' Names(j,:) '= arg;']);
      expectval = 0;
      
   end
   i = i + 1;
end

if expectval
   error(sprintf('Expected value for parameter ''%s''.', arg));
end

