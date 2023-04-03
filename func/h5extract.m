function [info,data] = h5extract(filepath, isBscan)
%[NRX,data] = h5extract(filepath)
%   输入部分：
%   filepath：   输入out文件的位置
%   （弃用）dir：输入想要提取的电场方向，默认探地朝向Ez（上下方向）
%   isBscan：    输入的文件是否是bscan数据(目前仅支持单通道BSCAN)
%
%   输出部分：
%   info：       此模型的信息
%   data：       所有接收天线的数据尺寸为（数据长度，天线个数）
    if isBscan
        dir = 'Ez';
        datapath = sprintf('/rxs/rx1/%s',dir);
        data = h5read(filepath,datapath);
        %获取文件的相关信息
        info = h5info(filepath).Attributes;
    else
        dir = 'Ez';
        datapath = sprintf('/rxs/rx1/%s',dir);
        NRX = size(h5info(filepath,'/rxs').Groups,1);
        len = size(h5read(filepath,datapath),1);
        
        data = zeros(len, NRX);
        %获取文件的相关信息
        info = h5info(filepath).Attributes;
    
        %读取模型对应的数据
        for i = 1:NRX
            datapath = sprintf('/rxs/rx%d/%s',i,dir);
            data(:,i) = h5read(filepath,datapath);
        end
    end
end

