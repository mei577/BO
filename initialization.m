% =========================================================================
% STEP 1: INITIALIZATION
% Purpose: Generate initial training data and record detailed results.
% =========================================================================

% 1. Define optimizable variables
vars = [
    optimizableVariable('para1', [4, 20]), 
    optimizableVariable('para2', [200, 800]),
    optimizableVariable('para3', [2, 20]),
    optimizableVariable('para4', [2, 20]),
    optimizableVariable('para5', [-15, 15])
];

% 2. Generate Initial Dataset using Latin Hypercube Sampling (LHS)
numInitialPoints = 20;
dimension = 5;
rng('default'); 
X_lhs_raw = lhsdesign(numInitialPoints, dimension, ...
    'criterion', 'maximin', ...
    'iterations', 50);

% 3. Scale LHS points to the actual parameter bounds
lb = [4, 200, 2, 2, -15];
ub = [20, 800, 20, 20, 15];
X_scaled = lb + (ub - lb) .* X_lhs_raw; 

% Create table for input parameters (Raw Data)
InitialX = array2table(X_scaled, 'VariableNames', {'para1', 'para2', 'para3', 'para4', 'para5'});

% 4. Evaluate initial points >>>>>  Experiments
InitialObjective = zeros(numInitialPoints, 1);
InitialConstraint = zeros(numInitialPoints, 1);

fprintf('Evaluating %d initial points...\n', numInitialPoints);
for i = 1:numInitialPoints
    [obj, con] = myObjectiveFunction(InitialX(i, :));
    InitialObjective(i) = obj;
    InitialConstraint(i) = con;
end

% 5. Record Data to Excel
filename = 'Initial_data.xlsx';

% Sheet1: Input parameters only (Raw Data)
writetable(InitialX, filename, 'Sheet', 'Sheet1');

% Sheet2: Detailed results including constraint, purity, and yieldInitialResults = InitialX;
InitialResults.constraint = InitialConstraint;
InitialResults.measured_purity = 98 - InitialConstraint; % Reconstruct purity from constraint
InitialResults.yield = -InitialObjective;                % Reconstruct yield from objective

writetable(InitialResults, filename, 'Sheet', 'Sheet2');

% 6. Save workspace for the main Bayesian Optimization script
save('init_data.mat', 'vars', 'InitialX', 'InitialObjective', 'InitialConstraint', 'filename', 'lb', 'ub');
disp('Initialization complete. Detailed results saved to Initial_data.xlsx (Sheet1 & Sheet2).');


%% --- Virtual Objective Function ---
function [objective, constraint] = myObjectiveFunction(x)
    p = [x.para1, x.para2, x.para3, x.para4, x.para5];
    
    % Simulated Yield Calculation (Noiseless model)
    measured_yield = 100 * exp(-sum(((p - [12, 500, 11, 11, 0]) ./ [8, 300, 9, 9, 15]).^2)); 
    
    % Simulated Purity Calculation (With Gaussian noise)
    true_purity = 98; 
    noise_purity = 0.1 * randn(); 
    measured_purity = true_purity + noise_purity;
    
    % Prepare outputs for bayesopt
    % 1. Objective: Minimize negative yield to maximize actual yield
    objective = -measured_yield;      
    % 2. Constraint: Purity >= 98 is represented as (98 - Purity) <= 0
    constraint = 98 - measured_purity; 
end