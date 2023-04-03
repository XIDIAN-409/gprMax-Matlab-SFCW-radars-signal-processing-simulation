function max_dxyz = calc_dxyz(fmax,epsmax)
%function max_dxyz = calc_dxyz(fmax,epsmax)
%同于计算gprMax模型的最大网格步长
%   fmax：仿真中出现的最大频率
%   epsmax：模型中最大的相对介电常数
%仿真时需要设置的网格步长不能大于max_dxyz
c = 3e8;
max_dxyz = c/(10*fmax*sqrt(epsmax));
end

