function [faxis, faxisshift, fout, foutshift] = user_fft(t ,signal, fs)
%[faxis, faxisshift, fout, foutshift] = user_fft(t ,signal, fs)
%   faxis:  对应的频率轴
%   fout:   对应的频域信号
%
%   t:      时间轴
%   signal: 时域信号
%   fs:     采样频率

n = size(t, 2);
faxis = fs*t*fs/n;
fout = fft(signal);

faxisshift = ((-n)/2:1:n/2-1)*fs/n;
foutshift = fftshift(fft(signal));

end

