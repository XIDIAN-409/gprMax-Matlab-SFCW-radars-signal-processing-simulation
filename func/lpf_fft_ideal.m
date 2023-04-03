function output = lpf_fft_ideal(fs,input,gate)
%output = lpf_fft_ideal(fs,input)
%   用于进行没有任何延时的理想低通滤波，将高于某个频率的信号全部滤除
%   fs：     采样频率
%   input：  输入信号（行向量）
%   gate：   通带截止频率，输入0时输出直流分量(有正负)
%   output： 输出信号（归一化）
    n = size(input,2);
    Y = fft(input);
    f = (-1/2:1/n:1/2-1/n)*fs;
    Y_shift = fftshift(Y);
    
    if gate == 0
        output = Y(1)/n;
    else
        Y_shift(find(f < -gate | f > gate)) = 0;
        Y = fftshift(Y_shift);
        output = ifft(Y);
        output = output/max(output);
    end
end

