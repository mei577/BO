% =========================================================================
% STEP2: Bayesian Optimization cPI
% DESCRIPTION: 
% This script implements a Bayesian Optimization (BO) loop for a 5-dimensional 
% chemical/physical system. 
%
% KEY FEATURES:
% 1. Data Continuity: Loads initial training data from 'Initial_data.xlsx'.
% 2. Real-time Persistence: Automatically updates 'bo_cPI.xlsx' after every 
%    iteration to prevent data loss.
% 3. Constraint Handling: Optimizes for maximum Yield while strictly 
%    maintaining a Purity threshold of >= 98%.
% 4. Global Search: Scans both initial and newly generated data to identify 
%    the global optimal feasible point.
%
% MATHEMATICAL FORMULATION:
% - Objective: Minimize (-Yield) to achieve Yield maximization.
% - Constraint: (98 - Purity) <= 0 to satisfy Purity >= 98%.
% =========================================================================

%% 1. Define Optimization Variables
% Define search space bounds for para1 through para5
vars = [
    optimizableVariable('para1', [4, 20]), 
    optimizableVariable('para2', [200, 800]),
    optimizableVariable('para3', [2, 20]),
    optimizableVariable('para4', [2, 20]),
    optimizableVariable('para5', [-15, 15])
];

%% 2. Load Initial Experimental Data
% Load data from Step 1 (initialization) to seed the BO model
input_file = 'Initial_data.xlsx';
if ~exist(input_file, 'file')
    error('Required file "Initial_data.xlsx" not found. Run Step 1 first.');
end

InitialX = readtable(input_file, 'Sheet', 'Sheet1');
InitialData = readtable(input_file, 'Sheet', 'Sheet2');

% Reconstruct objective and constraint values for MATLAB's solver
InitialObjective = -InitialData.yield;       
InitialConstraint = InitialData.constraint;  

%% 3. Execute Bayesian Optimization
% Set for 60 total evaluations (20 initial + 40 manual iterations)
results = bayesopt(@myObjectiveFunction, vars, ...
    'InitialX', InitialX, ...
    'InitialObjective', InitialObjective, ...
    'InitialConstraint', InitialConstraint, ... 
    'NumCoupledConstraints', 1, ...
    'AcquisitionFunctionName', 'probability-of-improvement', ...
    'IsObjectiveDeterministic', true, ... 
    'AreCoupledConstraintsDeterministic', false, ... 
    'MaxObjectiveEvaluations', 60, ... 
    'OutputFcn', @saveResultsToExcel, ... 
    'PlotFcn', {@plotMinObjective, @plotConstraintModels});

%% 4. Final Global Optimal Identification
% Extract full experimental history for analysis
allYields = -results.ObjectiveTrace; 
allConstraints = results.ConstraintsTrace;
isFeasible = allConstraints <= 0; 

if any(isFeasible)
    % Find the best result among all feasible points (Initial + BO)
    [maxYield, idxInFeasible] = max(allYields(isFeasible));
    feasibleIndices = find(isFeasible);
    bestGlobalIdx = feasibleIndices(idxInFeasible);
    
    fprintf('\n=========================================================\n');
    fprintf('GLOBAL OPTIMUM FOUND\n');
    disp('Best Parameters:');
    disp(results.XTrace(bestGlobalIdx, :));
    fprintf('Max Yield: %.4f | Purity: %.4f\n', maxYield, 98 - allConstraints(bestGlobalIdx));
    fprintf('=========================================================\n');
else
    warning('No points met the Purity >= 98%% constraint.');
end

%% --- Support Functions ---

function [objective, constraint] = myObjectiveFunction(x)
    % Prompts user for experimental results based on current parameters
    fprintf('\n--- Suggested Parameters ---\n');
    disp(x); 
    
    measured_yield = input('Enter Measured Yield: ');
    measured_purity = input('Enter Measured Purity: ');
    
    objective = -measured_yield;      
    constraint = 98 - measured_purity; 
end

function stop = saveResultsToExcel(results, state)
    stop = false; 
    % Real-time data logging to Excel
    if strcmp(state, 'iteration')
        output_file = 'bo_cPI.xlsx';
        T = results.XTrace;
        T.yield = -results.ObjectiveTrace;
        T.constraint = results.ConstraintsTrace;
        T.measured_purity = 98 - results.ConstraintsTrace;
        
        writetable(T, output_file, 'Sheet', 'Sheet1');
        fprintf('Progress auto-saved to %s.\n', output_file);
    end
end