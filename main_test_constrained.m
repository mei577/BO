vars = [
    optimizableVariable('para1',[4, 20]), 
    optimizableVariable('para2',[200, 800]),
    optimizableVariable('para3',[2, 20]),
    optimizableVariable('para4',[2, 20]),
    optimizableVariable('para5',[-15, 15])
    ];


results = bayesopt(@(x) test_con(x),vars,'IsObjectiveDeterministic',true,...
    'NumCoupledConstraints',1,'PlotFcn',...
    {@plotMinObjective,@plotConstraintModels},...
    'AcquisitionFunctionName','expected-improvement-plus','Verbose',0,'MaxObj', 60);
