clear;clc;
addpath(genpath("/work/Wei/Projects/WholeFishAnalyss/src"));
matPath="/work/public/Virginia Rutten/230324_f479_ubi_gcamp_bactin2_mcherry_9dpf_hypoxia_tiles/mat";
%% generate the folder
if ~exist(matPath,"dir")
    mkdir(matPath);
end
%%
tCnt=0;
for iFile=0:15
    disp(iFile);
    fileName=num2str(iFile,"%04.f");
    %% file path
    filePath="/work/public/Virginia Rutten/230324_f479_ubi_gcamp_bactin2_mcherry_9dpf_hypoxia_tiles/imag_tiles/" + ...
        "test_"+fileName+".nd2";
    
    %% get valid z slice in moving image
    reader = bfGetReader(convertStringsToChars(filePath));
    [X,Y,Z,T,~,optionTemplate.zRatio_mov]=readMeta(reader);
    
    for t=1:T
        dat_ch1=readOneFrame_uint16(reader,t,1);
        dat_ch2=readOneFrame_uint16(reader,t,2);
        tCnt=tCnt+1;
        save(fullfile(matPath,"dat"+tCnt+".mat"),"dat_ch1","dat_ch2");
    end
end