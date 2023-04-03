function [t, output_I,output_Q] = contsine(fs, fn, td, k)
%function [t, output] = contsine(fs, fn, k)
%输出一个适用于gprMax仿真的固定频率余弦信号
%   fs：采样频率
%   fn：信号频率
%   k：斜率系数
%   td：信号持续时间
ts = 1/fs;
t = 0:ts:td-ts;
An = k*fn*t;
An(find(An >= 1)) = 1;

output_I =  An.*cos(2*pi*fn*t);
output_Q = -An.*sin(2*pi*fn*t);
end

