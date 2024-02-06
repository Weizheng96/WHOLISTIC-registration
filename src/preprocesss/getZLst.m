function zLst=getZLst(dat_ref,dat_mov_Raw,option)


Z1=size(dat_ref,3);Z2=size(dat_mov_Raw,3);
corrMap=zeros(Z1,Z2);

for z1=1:Z1
    slice1=dat_ref(:,:,z1);
    slice1=slice1(:);
    parfor z2=1:Z2
        slice2=dat_mov_Raw(:,:,z2);
        slice2=slice2(:);
        R=corrcoef(slice1,slice2);
        corrMap(z1,z2)=R(2);
    end
end

b=option.zRatio_mov/option.zRatio_ref;

zlstRaw=0:b:Z2*b-1;
zIniRange=Z1-(Z2-1)*b;
meanCorrLst=zeros(1,zIniRange);
for i=1:zIniRange
    zlst=round(zlstRaw+i);
    meanCorrLst(i)=mean(corrMap(zlst+(0:Z2-1)*Z1));
end
[~,I]=max(meanCorrLst);

zLst=zlstRaw+I;


end