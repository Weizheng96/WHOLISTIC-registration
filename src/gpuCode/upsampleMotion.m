
function motion_current_temp=upsampleMotion(motion_current,x,y,z)

motion_current=motion_current*2;
[xp,yp,zp,~]=size(motion_current);



motion_current_temp=gpuArray(zeros(xp*2+1,yp*2+1,zp*2+1,3,"single"));

xG=gpuArray(1:2:xp*2);yG=gpuArray(1:2:yp*2);zG=gpuArray(1:2:zp*2);
for xCnt=0:1
    motion_current_temp(xG+xCnt,yG,zG,:)=motion_current;
end

motion_current_temp(:,yG+1,zG,:)=motion_current_temp(:,yG,zG,:);
motion_current_temp(:,:,zG+1,:) =motion_current_temp(:,:,zG,:);

if x==xp*2+1
    motion_current_temp(xp*2+1,:,:,:)=motion_current_temp(xp*2,:,:,:);
else
    motion_current_temp=motion_current_temp(1:x,:,:,:);
end

if y==yp*2+1
    motion_current_temp(:,yp*2+1,:,:)=motion_current_temp(:,yp*2,:,:);
else
    motion_current_temp=motion_current_temp(:,1:y,:,:);
end

if z==zp*2+1
    motion_current_temp(:,:,zp*2+1,:)=motion_current_temp(:,:,zp*2,:);
else
    motion_current_temp=motion_current_temp(:,:,1:z,:);
end


end
