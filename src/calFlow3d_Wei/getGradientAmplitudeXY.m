function data_g=getGradientAmplitudeXY(data1_tran,smFactor)

data1_tran = imgaussfilt(data1_tran,smFactor);

temp_diff1 = data1_tran(2,:,:) - data1_tran(1,:,:);
temp_diff2 = (data1_tran(3:end,:,:) - data1_tran(1:end-2,:,:))/2;
temp_diff3 = data1_tran(end,:,:) - data1_tran(end-1,:,:);
Ix = cat(1,temp_diff1,temp_diff2,temp_diff3);

temp_diff1 = data1_tran(:,2,:) - data1_tran(:,1,:);
temp_diff2 = (data1_tran(:,3:end,:) - data1_tran(:,1:end-2,:))/2;
temp_diff3 = data1_tran(:,end,:) - data1_tran(:,end-1,:);
Iy = cat(2,temp_diff1,temp_diff2,temp_diff3);

data_g=sqrt(Ix.^2+Iy.^2);

end

