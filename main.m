clear;clc;
filepath = 'impulse_lib\bscan_impulse_10m_merged.out';
f_start = 100e6;
delta_f = 1e6;
N = 3000;

ts = 1e-11;
fs = 1/ts;

td = 100e-9;

%% 提取HDF5中的仿真数据
[info, data] = h5extract(filepath,true);
I_lpf = zeros(size(data,1),N);
Q_lpf = zeros(size(data,1),N);
range_res = zeros(size(data,1),N);
%data = data.';
for k = 1:size(data,1)
    ht = data(k,:);
    
    for i = 1:N
        [t,output_I,output_Q] = contsine(fs,f_start+i*delta_f,td,0.25);
        
        yt = conv(output_I, ht);
        yt = yt(1:size(output_I,2));
        yt = yt/max(yt);
        y_mixer = mixer(yt,output_I);
        I_lpf(k,i) = lpf_fft_ideal(fs,y_mixer,0);
    
        yt = conv(output_Q, ht);
        yt = yt(1:size(output_Q,2));
        yt = yt/max(yt);
        y_mixer = mixer(yt,output_Q);
        Q_lpf(k,i) = lpf_fft_ideal(fs,y_mixer,0);
    end
    fprintf("%d/%d\n",k,size(data,1));
    IQ_res = I_lpf(k,:) + 1j*Q_lpf(k,:);
    range_res(k,:) = ifft(IQ_res);
end
B = N*delta_f;
ts = 1/B;
tt = 0:ts:(size(range_res,2)-1)*ts;
plot(tt,abs(range_res(1,:)));

img = abs(range_res(1:188,1:320).');
display = img;
display = display/max(max(display));
imagesc(display);
