%% addpath
addpath(genpath("/work/Wei/Projects/WholeFishAnalyss/src"));
%% load data
dataPath="/work/public/Virginia Rutten/221124_f338_ubi_gCaMP7f_bactin_mCherry_CAAX_8505_7dpf_hypoxia/anatomy/exp0/start";
cd(dataPath);
dat_raw = bfopen('221124_f338_ubi_gCaMP7f_bactin_mCherry_CAAX_7dpf_anat.nd2');

dat_raw1=dat_raw{1}(:,1);
dat_raw2=dat_raw{1}(:,2);
N=length(dat_raw1);
[X,Y]=size(dat_raw1{1});
[~,~,Z,C]=getSliceId3(dat_raw2{1});
dat=cell(C,1);
for c=1:C
    dat{c}=zeros(X,Y,Z,class(dat_raw1{1}));
end

for sliceCnt=1:N
    disp(sliceCnt+"/"+N);
    [z,c]=getSliceId3(dat_raw2{sliceCnt});
    dat{c}(:,:,z)=dat_raw1{sliceCnt};
end

clear dat_raw1 dat_raw2 dat_raw
%%
dat1_ana=dat{1};
dat2_ana=dat{2};


save("dat_ana","dat1_ana","dat2_ana","-v7.3");