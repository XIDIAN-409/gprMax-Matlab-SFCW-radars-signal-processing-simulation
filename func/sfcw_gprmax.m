function [tt,output] = sfcw_gprmax(fs,td,N,f_start,delta_f,amp)
%[tt,output] = sfcw_gprmax(fs,td,N,f_start,delta_f,amp)
%用于生成适用于gprMax的步进频连续波信号
%   fs：     采样频率
%   td：     每个频点的持续时间
%   N：      频点总数
%   f_start：起始频率
%   delta_f：步进频率
%   amp：    信号幅值
%
%   tt：     输出信号对应的时间信息
%   output： 输出信号


% td最好能被ts整除
c = 3e8;
ts = 1/fs;
t = 0:ts:td-ts;
tt = t;
output = amp*cos(2*pi*f_start*t);
for i = 1:N-1
    x = amp*cos(2*pi*(f_start+i*delta_f)*t);
    output = horzcat(output,x);
    tt = horzcat(tt,t+i*td);
end
% gprMax无法对一个完整的SFCW信号进行仿真，输出此txt文件无意义
% out = vertcat(tt, output);
% out = out.';
% save sfcw.txt -ascii out;
B = N*delta_f;
max_range = c/(2*delta_f);
range_res = c/(2*B);
T = N*td;

fprintf(['信号带宽：%.3f MHz\n' ...
    '最大无模糊距离：%.3f m\n' ...
    '距离分辨率：%.3f m\n' ...
    '最大频率：%.3f GHz\n' ...
    '滤波器理论通带上界：%.3f Hz\n' ...
    '信号持续时间：%.3f us \n'], ...
    B/1e6,max_range,range_res,(f_start+N*delta_f)*1e-9,1/(2*td),T*1e6);

end