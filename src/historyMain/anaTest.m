filePath="/work/public/Virginia Rutten/230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf/exp0/anat/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf001.nd2";

% filePath="/work/public/Virginia Rutten/230119_f391_ubi_gcamp_bact_mcherry_8849_8dpf_atropine/exp0/anat/" + ...
%     "230119_f389_ubi_gcamp_bact_mcherry_8849_8dpf_atropine.nd2";


reader = bfGetReader(convertStringsToChars(filePath));
[X,Y,Zana,T,C,zRatioAna]=readMeta(reader);


dat_ana=readOneFrame_double(reader,1,2);

filePath="/work/public/Virginia Rutten/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf/exp0/imag/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf002.nd2";
reader = bfGetReader(convertStringsToChars(filePath));
[~,~,Zref,~,~,zRatioRef]=readMeta(reader);
dat_ref=readOneFrame_double(reader,1,2);

corScoreMat=zeros(Zana,Zref);
for zCnt1=1:Zana
    disp(zCnt1)
    for zCnt2=1:Zref
        temp1=dat_ana(:,:,zCnt1);temp2=dat_ref(:,:,zCnt2);
        temp1=temp1(:);temp2=temp2(:);
        temp1=temp1./std(temp1);temp2=temp2./std(temp2);
        corScoreMat(zCnt1,zCnt2)=mean(temp1.*temp2);
    end
end

imagesc(corScoreMat);