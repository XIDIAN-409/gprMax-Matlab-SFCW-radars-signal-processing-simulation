function [output_I, output_Q, t_total] = sfcw(t, tau, Td, fs, steps, phase, delta_freq, start_freq)
%SFCW 用于生成步进频连续波信号
%   [output_I, output_Q, t_total] = sfcw(t, tau, Td, fs, steps, phase, delta_freq, start_freq)
%   output_I:   输出信号
%   output_Q：  与输出信号正交的另一个信号，用于IQ混频
%   t_total：   输出信号的总长度 
%   
%   t：          单个频率点的驻留时间
%   tau：        回波的延时
%   steps：      多少次变频
%   delta_freq： 频率间隔为多少
%   start_freq： 初始频率
%   fs:          采样频率（t变化间隔的倒数）
%   phase:       信号的相位
%   Td:          每一个频点的驻留时间,N/fs

f = start_freq;                %100MHz
w = 2*pi*f;
% output_I = 0.5*(exp(1j*(w*(t-tau) + phase)) + exp(-1j*(w*(t-tau) + phase)));
% output_Q = (exp(1j*(w*(t-tau) + phase)) - exp(-1j*(w*(t-tau) + phase)))/(-2j);
output_I = cos(w*(t-tau) + phase);
output_Q = cos(w*(t-tau) + phase + pi/2);
t = 1/fs:1/fs:Td;
t_total = t;

for i = 1:steps
    f = start_freq + i*delta_freq;
    w = 2*pi*f;
    x = cos(w*(t-tau) + phase);
    y = cos(w*(t-tau) + phase + pi/2);
    output_I = horzcat(output_I, x);
    output_Q = horzcat(output_Q, y);
    t_total = horzcat(t_total, t+i*Td);
end
    output_I(find(t_total-tau)<=0) = 0;
    output_Q(find(t_total-tau)<=0) = 0;
end

