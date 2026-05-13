% =========================================================================
% STEP2: Bayesian Optimization HDM
% DESCRIPTION: 
% This script implements a HYBRID Bayesian Optimization strategy:
% 1. Phase 1 (75%): Uses 'expected-improvement-plus' (cEI) for exploration.
% 2. Phase 2 (25%): Uses 'probability-of-improvement' (cPI) for fine-tuning.
%
% TOTAL NEW ITERATIONS: 40
% SPLIT: 75% cEI (30 iterations), 25% cPI (10 iterations)
% =========================================================================

%% 1. Configuration and Parameter Setup
total_new_iters = 40;
split_percent = 75;

% Calculate number of iterations for each phase (rounding to nearest integer)
num_ei_iters = round(total_new_iters * (split_percent / 100));
num_pi_iters = total_new_iters - num_ei_iters;

vars = [
    optimizableVariable('para1', [4, 20]), 
    optimizableVariable('para2', [200, 800]),
    optimizableVariable('para3', [2, 20]),
    optimizableVariable('para4', [2, 20]),
    optimizableVariable('para5', [-15, 15])
];

%% 2. Load Initial Data
input_file = 'Initial_data.xlsx';
if ~exist(input_file, 'file')
    error('Initial_data.xlsx not found. Please run Step 1 (initialization) first.');
end

InitialX = readtable(input_file, 'Sheet', 'Sheet1');
InitialData = readtable(input_file, 'Sheet', 'Sheet2');

% Number of initial points (usually 20)
num_initial = height(InitialX);

%% 3. Phase 1: Constrained Expected Improvement (cEI)
fprintf('\n--- STARTING PHASE 1: cEI (%d Iterations) ---\n', num_ei_iters);

results_phase1 = bayesopt(@myObjectiveFunction, vars, ...
    'InitialX', InitialX, ...
    'InitialObjective', -InitialData.yield, ...
    'InitialConstraint', InitialData.constraint, ...
    'NumCoupledConstraints', 1, ...
    'AcquisitionFunctionName', 'expected-improvement-plus', ...
    'IsObjectiveDeterministic', true, ... 
    'AreCoupledConstraintsDeterministic', false, ... 
    'MaxObjectiveEvaluations', num_initial + num_ei_iters, ... % 20 + 30 = 50
    'OutputFcn', @saveResultsToExcel, ... 
    'PlotFcn', {@plotMinObjective, @plotConstraintModels});

%% 4. Phase 2: Constrained Probability of Improvement (cPI)
fprintf('\n--- STARTING PHASE 2: cPI (%d Iterations) ---\n', num_pi_iters);

% Use ALL data from Phase 1 as the initial set for Phase 2
results_final = bayesopt(@myObjectiveFunction, vars, ...
    'InitialX', results_phase1.XTrace, ...
    'InitialObjective', results_phase1.ObjectiveTrace, ...
    'InitialConstraint', results_phase1.ConstraintsTrace, ...
    'NumCoupledConstraints', 1, ...
    'AcquisitionFunctionName', 'probability-of-improvement', ... % Switched to PI
    'IsObjectiveDeterministic', true, ... 
    'AreCoupledConstraintsDeterministic', false, ... 
    'MaxObjectiveEvaluations', num_initial + total_new_iters, ... % 50 + 10 = 60
    'OutputFcn', @saveResultsToExcel, ... 
    'PlotFcn', {@plotMinObjective, @plotConstraintModels});

%% 5. Global Best Identification
allYields = -results_final.ObjectiveTrace; 
allConstraints = results_final.ConstraintsTrace;
isFeasible = allConstraints <= 0; 

if any(isFeasible)
    [maxYield, idxInFeasible] = max(allYields(isFeasible));
    feasibleIndices = find(isFeasible);
    bestGlobalIdx = feasibleIndices(idxInFeasible);
    
    fprintf('\n=========================================================\n');
    fprintf('HYBRID OPTIMIZATION COMPLETED\n');
    disp('Best Parameters Found Across All Phases:');
    disp(results_final.XTrace(bestGlobalIdx, :));
    fprintf('Max Yield: %.4f | Purity: %.4f\n', maxYield, 98 - allConstraints(bestGlobalIdx));
    fprintf('=========================================================\n');
end

%% --- Support Functions ---

function [objective, constraint] = myObjectiveFunction(x)
    fprintf('\n--- Manual Input Required ---\n');
    disp(x); 
    measured_yield = input('Enter Measured Yield: ');
    measured_purity = input('Enter Measured Purity: ');
    objective = -measured_yield;      
    constraint = 98 - measured_purity; 
end

function stop = saveResultsToExcel(results, state)
    stop = false; 
    if strcmp(state, 'iteration')
        output_file = 'bo_HDM.xlsx';
        T = results.XTrace;
        T.yield = -results.ObjectiveTrace;
        T.constraint = results.ConstraintsTrace;
        T.measured_purity = 98 - results.ConstraintsTrace;
        writetable(T, output_file, 'Sheet', 'Sheet1');
        fprintf('Progress auto-saved to %s.\n', output_file);
    end
end