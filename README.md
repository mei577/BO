本包共包含五个文件。



latin：

使用拉丁超立方抽样获取初始数据点，运行后会获得initial_data.xlsx。

每行代表一组设计变量组合，进行实验，将数据补充至表格内，运行main。



test ：

简单的测试程序。运行后会显示实验进程图以及实验结果。

假设实验速度极快，实验进程应如折线图所示。



test_function：

简单的测试函数。



main：

基于initial_data.xlsx的数据进行贝叶斯优化，默认求目标函数的最小值。

目前只能根据MaxObj这一参数(最大总实验次数) 停止程序。

每次迭代时会输出目标函数值、预期目标函数值、历史最佳值等信息。



objective：

需手动输入实验结果的函数。

可将新实验数据保存至initial_data.xlsx。

即便实验半途而废，也能留下数据。





main_constrained:

执行含约束优化的主程序。

读取的表格文件名为initial_data_con.xlsx，如用latin生成，注意更改文件名

输入数据前应阅读“约束违反度”计算方式





objective_con:

与main_constrained配套的实验数据写入函数





main_test_constrained：

test_con：

二维含约束测试函数
