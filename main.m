clear all 


% 变量设置及上下界
vars = [
    optimizableVariable('para1',[4, 20]), 
    optimizableVariable('para2',[200, 800]),
    optimizableVariable('para3',[2, 20]),
    optimizableVariable('para4',[2, 20]),
    optimizableVariable('para5',[-15, 15]),
    ];


% 将initial_data中的数据补充完毕后，读取excel文件中的数据
initial_data = readtable('initial_data.xlsx','Sheet',1);
initialX = initial_data(:, 1:5);
initialObjective = table2array(initial_data(:, 6));


% Optimization & output
% MaxObj后的参数为总实验次数，包含initial_data
results = bayesopt(@(params) objective(params), vars, ...
     ...
    'InitialX', initialX, ...
    'InitialObjective', initialObjective,...
    'AcquisitionFunctionName', 'expected-improvement', ...
    'MaxObj', 20);

% test
%results = bayesopt(@(params) objective_functions(params), vars, ...
    %'AcquisitionFunctionName', 'expected-improvement', ...
    %'MaxObj', 100);