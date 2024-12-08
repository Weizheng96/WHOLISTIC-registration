%% 20230620, Wei Zheng
clear;clc;
addpath(genpath("/work/Wei/Projects/WholeFishAnalyss/src"));

%% file path
filePath="/work/public/Virginia Rutten/230623_f509_bactin_mcharry_phox2b_egfp_8dpf/exp2/nd2/" + ...
    "230623_f509_bactin_mcharry_phox2b_egfp_8dpf008_cropped001.nd2";

resPathName="/work/public/Virginia Rutten/230623_f509_bactin_mcharry_phox2b_egfp_8dpf/exp2/f509_HZRv2d2_r5_p0d01_20230922";
%% generate the folder
dataResPathName=resPathName+"/hdf5";
%% get valid z slice in moving image
reader = bfGetReader(convertStringsToChars(filePath));
[X,Y,Z,T,~,option.zRatio]=readMeta(reader);
%%
MSE_raw=zeros(T,1);
MSE_corrected=zeros(T,1);
dat_ref=readOneFrame_single(reader,1,1);
tic
for t=2:T
    disp(t+"/"+T);toc
    dat_raw=readOneFrame_single(reader,t,1);
    dat_corrected=h5read(fullfile(dataResPathName,"dat_t"+t+".hdf5"),"/ch1");
    MSE_raw(t)=mean((dat_raw-dat_ref).^2,'all');
    MSE_corrected(t)=mean((dat_corrected-dat_ref).^2,'all');
end

save(fullfile(resPathName,"MSE.mat"),"MSE_corrected","MSE_raw");
writematrix(MSE_corrected,fullfile(resPathName,"MSE_corrected.xls"));
writematrix(MSE_raw,fullfile(resPathName,"MSE_raw.xls"));