%% addpath
addpath(genpath("/work/Wei/Projects/WholeFishAnalyss/src"));
%% load data
dataPath="/work/public/Virginia Rutten/230119_f391_ubi_gcamp_bact_mcherry_8849_8dpf_atropine/exp0/imag";
cd(dataPath);
dat_raw = bfopen('230119_f389_ubi_gcamp_bact_mcherry_8849_8dpf_atropine001.nd2');

dat_raw1=dat_raw{1}(:,1);
dat_raw2=dat_raw{1}(:,2);
N=length(dat_raw1);
[X,Y]=size(dat_raw1{1});
[~,~,~,Z,C,T]=getSliceId2(dat_raw2{1});
dat=cell(C,1);
for c=1:C
    dat{c}=zeros(X,Y,Z,T,class(dat_raw1{1}));
end

for sliceCnt=1:N
    disp(sliceCnt+"/"+N);
    [z,c,t]=getSliceId2(dat_raw2{sliceCnt});
    dat{c}(:,:,z,t)=dat_raw1{sliceCnt};
end

clear dat_raw1 dat_raw2 dat_raw
%%
cd("/work/public/Virginia Rutten/230119_f391_ubi_gcamp_bact_mcherry_8849_8dpf_atropine/matfile");
dat1=dat{1}(:,:,:,1:100);
dat2=dat{2}(:,:,:,1:100);
save("dat_crop","dat1","dat2","-v7.3");
%%
dat1=dat{1}; dat2=dat{2};
save("dat","dat1","dat2","-v7.3");