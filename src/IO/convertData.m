%% addpath
addpath(genpath("/work/Wei/Projects/WholeFishAnalyss/src"));
%% load data
dataPath="/work/public/Virginia Rutten/221111_f310_ubi_bact2b_h2b_mcherry_7dpf/exp0";
cd(dataPath);
dat_raw = bfopen('221111_f310_ubi_bact2b_h2b_mcherry_7dpf_timeseries.nd2');

dat_raw1=dat_raw{1}(:,1);
dat_raw2=dat_raw{1}(:,2);
N=length(dat_raw1);
[X,Y]=size(dat_raw1{1});
[~,~,Z,T]=getSliceId(dat_raw2{1});
dat=zeros(X,Y,Z,T,class(dat_raw1{1}));

for sliceCnt=1:N
    disp(sliceCnt+"/"+N);
    [z,t]=getSliceId(dat_raw2{sliceCnt});
    dat(:,:,z,t)=dat_raw1{sliceCnt};
end

clear dat_raw1 dat_raw2 dat_raw
%%
z=8;
t=54:62;
dat_crop=squeeze(dat(:,:,z,t));
dat_crop=mat2gray(double(dat_crop));
save("dat_crop","dat_crop");