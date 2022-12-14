function [param,fval,output,exitflag] = fr_function_fit(funfcn,param,obs,options,varargin)
%fr_FUNCTION_FIT Fitting of a function to observations using various methods.
%   PARAM = fr_FUNCTION_FIT(FUN,PARAM0,OBS,[],X) returns a vector PARAM that is a local
%   minimizer of the parameters used in FUN to the observations provided in OBS 
%   (usually FUN is an M-file: FUN.M). The minimazation is local, i.e. PARAM may depend
%   on starting the vector PARAM0. FUN should return a scalar function value when 
%   called with feval: F=feval(FUN,PARAM,X1,X2,...).  See below for more options for FUN.
%
%   PARAM = fr_FUNCTION_FIT(FUN,PARAM0,OBS,OPTIONS)  minimizes with the default optimization
%   parameters replaced by values in the structure OPTIONS, created
%   with the fr_OPTIMSET function.  See fr_OPTIMSET for details.  fr_FUNCTION_FIT uses
%   these options: Display, TolX, TolFun, MaxFunEvals, MaxIter, and Method. 
%
%   PARAM = fr_FUNCTION_FIT(FUN,PARAM0,OBS,OPTIONS,X1,X2,...) provides for the 
%   arguments which are passed to the objective function, F=feval(FUN,PARAM,X1,X2,...).
%   Pass an empty matrix for OPTIONS to use the default values.
%   (Use OPTIONS = [] as a place holder if no options are set.)
%
%   [PARAM,FVAL]= fr_FUNCTION_FIT(...) returns a vector of values of the fitted 
%   function FUN(PARAM,X1,X2,...)
%
%   [PARAM,FVAL,OUTPUT] = fr_FUNCTION_FIT(...) returns a structure
%   OUTPUT with the number of iterations taken in OUTPUT.iterations. Other statistics
%   provided include the minimized M estimate, the sum of squared deviation from the fitted
%   function (in the OLS case that is the same as the M estimate), and R2 in an OLS sense.
%
%   [PARAM,FVAL,OUTPUT,EXITFLAG] = fr_FUNCTION_FIT(...) returns a string EXITFLAG that 
%   describes the exit condition of fr_FUNCTION_FIT.  
%   If EXITFLAG is:
%     1 then fr_FUNCTION_FIT converged with a solution PARAM.
%     0 then the maximum number of iterations was reached.
%   
%   The argument FUN can be an inline function:
%      f = inline('param(1).*x + param(2).*y','param','x');
%      x = fr_function_fit(f,param0,obs,options,x);
%
%   fr_FUNCTION_FIT uses the Nelder-Mead simplex (direct search) method to minimze the 
%   deviation of the desired M-estimate. M-estimates implemented are ordinary least square
%   fit (option.Method = 'OLS', the default), mean average deviation (option.Method = 'MAD')
%   and the assumption of Cauchy distributed errors (option.Method = 'CAUCHY')
%
%   See also FMINBND, fr_OPTIMSET, OPTIMGET. 

%   Reference: Jeffrey C. Lagarias, James A. Reeds, Margaret H. Wright,
%   Paul E. Wright, "Convergence Properties of the Nelder-Mead Simplex
%   Algorithm in Low Dimensions", May 1, 1997.  To appear in the SIAM 
%   Journal of Optimization.
%   On the use M-estimate see Numerical Recipies 14.6 'Robust Estimation'
%
%   This function is a derivative of MATLAB's fminsearch
%   kai* June 21, 2001

defaultopt = fr_optimset('display','final','maxiter','200*numberOfVariables',...
   'maxfunevals','200*numberOfVariables','Method','OLS','TolX',1e-4,'TolFun',1e-4);
% If just 'defaults' passed in, return the default options in param
if nargin==1 & nargout <= 1 & isequal(funfcn,'defaults')
   param = defaultopt;
   return
end

% if nargin<3, options = []; end
% kai*
if nargin<4, options = []; end
%end
n = prod(size(param));
numberOfVariables = n;

options = fr_optimset(defaultopt,options);
printtype = optimget(options,'display');
tolx = optimget(options,'tolx');
tolf = optimget(options,'tolfun');
maxfun = optimget(options,'maxfuneval');
maxiter = optimget(options,'maxiter');
% In case the defaults were gathered from calling: fr_optimset('fr_FUNCTION_FIT'):
if ischar(maxfun)
   maxfun = eval(maxfun);
end
if ischar(maxiter)
   maxiter = eval(maxiter);
end

switch printtype
case {'none','off'}
   prnt = 0;
case 'iter'
   prnt = 2;
case 'final'
   prnt = 1;
case 'simplex'
   prnt = 3;
otherwise
   prnt = 1;
end

header = ' Iteration   Func-count     min f(x)         Procedure';

% Convert to inline function as needed.
funfcn = fcnchk(funfcn,length(varargin));

n = prod(size(param));

% Initialize parameters
rho = 1; chi = 2; psi = 0.5; sigma = 0.5;
onesn = ones(1,n);
two2np1 = 2:n+1;
one2n = 1:n;

% Set up a simplex near the initial guess.
paramin = param(:); % Force paramin to be a column vector
v = zeros(n,n+1); fv = zeros(1,n+1);
v = paramin;    % Place input guess in the simplex! (credit L.Pfeffer at Stanford)
param(:) = paramin;    % Change param to the form expected by funfcn 

% fv = feval(funfcn,x,varargin{:}); 
% kai*
fv = minimizer(funfcn,param,obs,options,varargin{:}); 
% end

% Following improvement suggested by L.Pfeffer at Stanford
usual_delta = 0.05;             % 5 percent deltas for non-zero terms
zero_term_delta = 0.00025;      % Even smaller delta for zero elements of param
for j = 1:n
   y = paramin;
   if y(j) ~= 0
      y(j) = (1 + usual_delta)*y(j);
   else 
      y(j) = zero_term_delta;
   end  
   v(:,j+1) = y;
   param(:) = y; 
    % f = feval(funfcn,x,varargin{:});
    % kai*
    f = minimizer(funfcn,param,obs,options,varargin{:}); 
    % end
  fv(1,j+1) = f;
end     

% sort so v(1,:) has the lowest function value 
[fv,j] = sort(fv);
v = v(:,j);

how = 'initial';
itercount = 1;
func_evals = n+1;
if prnt == 2
   disp(' ')
   disp(header)
   disp([sprintf(' %5.0f        %5.0f     %12.6g         ', itercount, func_evals, fv(1)), how]) 
elseif prnt == 3
   clc
   formatsave = get(0,{'format','formatspacing'});
   format compact
   format short e
   disp(' ')
   disp(how)
   v
   fv
   func_evals
end
exitflag = 1;

% Main algorithm
% Iterate until the diameter of the simplex is less than tolx
%   AND the function values differ from the min by less than tolf,
%   or the max function evaluations are exceeded. (Cannot use OR instead of AND.)
while func_evals < maxfun & itercount < maxiter
   if max(max(abs(v(:,two2np1)-v(:,onesn)))) <= tolx & ...
         max(abs(fv(1)-fv(two2np1))) <= tolf
      break
   end
   how = '';
   
   % Compute the reflection point
   
   % xbar = average of the n (NOT n+1) best points
   xbar = sum(v(:,one2n), 2)/n;
   xr = (1 + rho)*xbar - rho*v(:,end);
   param(:) = xr; 
   % fxr = feval(funfcn,x,varargin{:});
   % kai*
    fxr = minimizer(funfcn,param,obs,options,varargin{:});
    % end
    
   func_evals = func_evals+1;
   
   if fxr < fv(:,1)
      % Calculate the expansion point
      xe = (1 + rho*chi)*xbar - rho*chi*v(:,end);
      param(:) = xe; 
        % fxe = feval(funfcn,x,varargin{:});
        % kai*
        fxe = minimizer(funfcn,param,obs,options,varargin{:});
        % end
      func_evals = func_evals+1;
      if fxe < fxr
         v(:,end) = xe;
         fv(:,end) = fxe;
         how = 'expand';
      else
         v(:,end) = xr; 
         fv(:,end) = fxr;
         how = 'reflect';
      end
   else % fv(:,1) <= fxr
      if fxr < fv(:,n)
         v(:,end) = xr; 
         fv(:,end) = fxr;
         how = 'reflect';
      else % fxr >= fv(:,n) 
         % Perform contraction
         if fxr < fv(:,end)
            % Perform an outside contraction
            xc = (1 + psi*rho)*xbar - psi*rho*v(:,end);
            param(:) = xc; 
            % fxc = feval(funfcn,x,varargin{:});
            % kai*
            fxc = minimizer(funfcn,param,obs,options,varargin{:});
            % end
            func_evals = func_evals+1;
            
            if fxc <= fxr
               v(:,end) = xc; 
               fv(:,end) = fxc;
               how = 'contract outside';
            else
               % perform a shrink
               how = 'shrink'; 
            end
         else
            % Perform an inside contraction
            xcc = (1-psi)*xbar + psi*v(:,end);
            param(:) = xcc; 
            % fxcc = feval(funfcn,x,varargin{:});
            % kai*
            fxcc = minimizer(funfcn,param,obs,options,varargin{:});
            % end

            func_evals = func_evals+1;
            
            if fxcc < fv(:,end)
               v(:,end) = xcc;
               fv(:,end) = fxcc;
               how = 'contract inside';
            else
               % perform a shrink
               how = 'shrink';
            end
         end
         if strcmp(how,'shrink')
            for j=two2np1
               v(:,j)=v(:,1)+sigma*(v(:,j) - v(:,1));
               param(:) = v(:,j); 
                % fv(:,j) = feval(funfcn,x,varargin{:});
                % kai*
                fv(:,j) = minimizer(funfcn,param,obs,options,varargin{:});
                % end
            end
            func_evals = func_evals + n;
         end
      end
   end
   [fv,j] = sort(fv);
   v = v(:,j);
   itercount = itercount + 1;
   if prnt == 2
   disp([sprintf(' %5.0f        %5.0f     %12.6g         ', itercount, func_evals, fv(1)), how]) 
   elseif prnt == 3
      disp(' ')
      disp(how)
      v
      fv
      func_evals
   end  
end   % while


param(:) = v(:,1);
if prnt == 3,
   % reset format
   set(0,{'format','formatspacing'},formatsave);
end
output.iterations = itercount;
output.funcCount = func_evals;
output.algorithm = 'Nelder-Mead simplex direct search';

% kai*
% Calculate function values
fval  = feval(funfcn,param,varargin{:});

% Calculate some of the basic statistics
output.m_est = min(fv); 
output.res   = sum((obs - fval).^2);
       total = sum((obs - mean(obs)).^2);
output.R2    = 1.0 - output.res/total;

%end

if func_evals >= maxfun 
   if prnt > 0
      disp(' ')
      disp('Exiting: Maximum number of function evaluations has been exceeded')
      disp('         - increase MaxFunEvals option.')
      msg = sprintf('         Current function value: %f \n', fval);
      disp(msg)
   end
   exitflag = 0;
elseif itercount >= maxiter 
   if prnt > 0
      disp(' ')
      disp('Exiting: Maximum number of iterations has been exceeded')
      disp('         - increase MaxIter option.')
      msg = sprintf('         Current function value: %f \n', fval);
      disp(msg)
   end
   exitflag = 0; 
else
   if prnt > 0
      convmsg1 = sprintf([ ...
         '\nOptimization terminated successfully:\n',...
         ' the current param satisfies the termination criteria using OPTIONS.TolX of %e \n',...
         ' and F(param) satisfies the convergence criteria using OPTIONS.TolFun of %e \n'
          ],options.TolX, options.TolFun);
      disp(convmsg1)
      exitflag = 1;
   end
end

function f = minimizer(funfcn,param,obs,options,varargin)
y_hat = feval(funfcn,param,varargin{:});
switch upper(options.Method)
case 'OLS'
    f = sum((y_hat-obs).^2); 
case 'MAD'
    f = sum(abs(y_hat-obs)); 
case 'CAUCHY'
    f = sum(log(1+0.5.*(y_hat-obs).^2)); 
end

return


