vars = [
    optimizableVariable('para1',[4, 20]), 
    optimizableVariable('para2',[200, 800]),
    optimizableVariable('para3',[2, 20]),
    optimizableVariable('para4',[2, 20]),
    optimizableVariable('para5',[-15, 15])
    ];

% 前五列为输入变量，第六列为实验数据1原始数据
% 第七列为约束违反度，其值=规定值-实验数据2
% 负数表示满足约束，其他情况代表不满足约束
initial_data = readtable('initial_data_con.xlsx','Sheet',1);
result = initial_data(:, end-1);
violation = initial_data(:, end);
initialX = initial_data(:, 1:end-2);
initialConstraintViolations = table2array(violation);
initialObjective = table2array(result);


results = bayesopt( @(x) objective_con(x),vars,'IsObjectiveDeterministic',true,...
    'InitialX', initialX, ...
    'InitialObjective', initialObjective,...
    'InitialConstraintViolations', initialConstraintViolations,...
    'NumCoupledConstraints',1,'PlotFcn',...
    {@plotMinObjective,@plotConstraintModels},...
    'AcquisitionFunctionName','expected-improvement-plus','Verbose',0,'MaxObj', 60);
