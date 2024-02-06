function motion_current=getMotion_Wei_v15d2(dat_mov,dat_ref,smoothPenalty_raw)
%% v15d2: rewrite the spatial penalty

%% parameters need to adjust
layer_num=3;              % pyramid layer num
iterNum=20;
r=5;
%% for test
tempz=11;

%% parameters don't need to adjust
zRatio_raw=27;
SZ=size(dat_mov);

%% multi-scale loop
for layer = layer_num:-1:0

    %% dowmsample for current scale
%     smoothPenalty=smoothPenalty_raw*2^layer;
    smoothPenalty=smoothPenalty_raw;
    data1 = gpuArray(imresize3(dat_mov, [round(SZ(1:2)/2^layer) SZ(3)]));
    data2 = gpuArray(imresize3(dat_ref, [round(SZ(1:2)/2^layer) SZ(3)]));
    [x,y,z] = size(data1);

    location_raw=zeros(x,y,z,3);
    location_raw(:,:,:,1)=ones(x,y,z).*reshape(1:x,x,1,1);
    location_raw(:,:,:,2)=ones(x,y,z).*reshape(1:y,1,y,1);
    location_raw(:,:,:,3)=ones(x,y,z).*reshape(1:z,1,1,z);

    zRatio=zRatio_raw/2^layer;
    movRange=[r r min(r/zRatio,0.4)];
    
    %% initilize the motion of each layer
    if layer == layer_num
        motion_current = gpuArray(zeros(x,y,z,3));
    else
        motion_current_temp=gather(motion_current);
        motion_current=zeros(x,y,z,3);
        motion_current(:,:,:,1) = imresize3(motion_current_temp(:,:,:,1), [x,y,z],"linear")*2;
        motion_current(:,:,:,2) = imresize3(motion_current_temp(:,:,:,2), [x,y,z],"linear")*2;
        motion_current(:,:,:,3) = imresize3(motion_current_temp(:,:,:,3), [x,y,z],"linear");
        motion_current=gpuArray(motion_current);
    end
    
    [x_ind,y_ind,z_ind] = ind2sub(size(data1),1:x*y*z);

    %% for test
    temp1=zeros(x,y,iterNum);temp2=zeros(x,y,iterNum);
    temp3=zeros(x,y,iterNum);temp4=zeros(x,y,iterNum);
    temp5=zeros(x,y,iterNum);temp6=zeros(x,y,iterNum);
    errorHistory=zeros(iterNum,1);

    %% update motion loop
    fprintf("\nDownsample:"+layer+"\n");
    for iter = 1:iterNum
        %% get corrected data
        data1_tran=correctMotion_Wei_v2(data1,motion_current);
       
        %% get spatial gradient
        [Ix,Iy,Iz]=getSpatialGradient_Wei(data1_tran);
       
        %% get temporal difference
        It = data2-data1_tran;
        It = imfilter(It,ones(3)/9,'replicate','same','corr');
    
        %% get motion update of control points
        AverageFilter=ones(r*2+1);
        xG=r+1:2*r+1:x;yG=r+1:2*r+1:y;zG=1:z;
        stepFactor=1;
%         stepFactor=min((iter-1)/3,1);

        Ixx = imfilter(Ix.^2 ,AverageFilter,'replicate','same','corr');
        Ixy = imfilter(Ix.*Iy,AverageFilter,'replicate','same','corr');
        Ixz = imfilter(Ix.*Iz,AverageFilter,'replicate','same','corr');
        Iyy = imfilter(Iy.^2 ,AverageFilter,'replicate','same','corr');
        Iyz = imfilter(Iy.*Iz,AverageFilter,'replicate','same','corr');
        Izz = imfilter(Iz.^2 ,AverageFilter,'replicate','same','corr');
        Ixt = imfilter(Ix.*It,AverageFilter,'replicate','same','corr');
        Iyt = imfilter(Iy.*It,AverageFilter,'replicate','same','corr');
        Izt = imfilter(Iz.*It,AverageFilter,'replicate','same','corr');

        Ixx = Ixx(xG,yG,zG);
        Ixy = Ixy(xG,yG,zG);
        Ixz = Ixz(xG,yG,zG);
        Iyy = Iyy(xG,yG,zG);
        Iyz = Iyz(xG,yG,zG);
        Izz = Izz(xG,yG,zG);
        Ixt = Ixt(xG,yG,zG);
        Iyt = Iyt(xG,yG,zG);
        Izt = Izt(xG,yG,zG);

        patchConnectNum=(r*2+1)^2;
        smoothPenaltySum=smoothPenalty*stepFactor*patchConnectNum;
        neiSum=smoothPenalty*stepFactor*(getNeiSum2(motion_current(xG,yG,zG,:),1)/8-motion_current(xG,yG,zG,:))*patchConnectNum;
%         neiSum=neiSum(xG,yG,zG,:);
    
        motion_update=getFlow3_withPenalty4(Ixx,Ixy,Ixz,Iyy,Iyz,Izz,Ixt,Iyt,Izt,smoothPenaltySum,neiSum,zRatio);
        %% the control points can't move out of the corresponding patch
        for dirNum=1:3
            motion_update(:,:,:,dirNum)= min( movRange(dirNum),motion_update(:,:,:,dirNum));
            motion_update(:,:,:,dirNum)= max(-movRange(dirNum),motion_update(:,:,:,dirNum));
        end
        %% project the control points' motion update from current axis to original axis
        xGL=length(xG);yGL=length(yG);location_current=motion_current+location_raw;

        x_new=ones(xGL,yGL,z).*xG';
        y_new=ones(xGL,yGL,z).*yG;
        z_new=ones(xGL,yGL,z).*reshape(zG,1,1,z);

        location_previous_cp=motion_update;
        for dirNum=1:3
            temp_phi=gather(location_current(:,:,:,dirNum));
            temp_phi=interp3(temp_phi,y_new,x_new,z_new);
            location_previous_cp(:,:,:,dirNum)=temp_phi;  
        end

        x_new=x_new+motion_update(:,:,:,1); x_new=max(x_new,1); x_new=min(x_new,x);
        y_new=y_new+motion_update(:,:,:,2); y_new=max(y_new,1); y_new=min(y_new,y);
        z_new=z_new+motion_update(:,:,:,3); z_new=max(z_new,1); z_new=min(z_new,z);

        location_current_cp=motion_update;
        for dirNum=1:3
            temp_phi=gather(location_current(:,:,:,dirNum));
            temp_phi=interp3(temp_phi,y_new,x_new,z_new);
            location_current_cp(:,:,:,dirNum)=temp_phi;  
        end
        motion_update=location_current_cp-location_previous_cp;
        %% get all pixels' the motion update based on control points' motion update
        x_new = (x_ind-r-1)/(2*r+1)+1;
        x_new = min(max(x_new,1),size(motion_update,1));
        y_new = (y_ind-r-1)/(2*r+1)+1;
        y_new = min(max(y_new,1),size(motion_update,2));
        z_new = z_ind;
        phi_gradient_temp=motion_update;
        motion_update=motion_current;
        for dirNum=1:3
            temp_phi=gather(phi_gradient_temp(:,:,:,dirNum));
            motion_update(:,:,:,dirNum)= gpuArray(reshape(interp3(temp_phi,y_new,x_new,z_new),[ x y z]));  
        end
        %% add the motion update to current motion
        motion_current = motion_current+motion_update;

        %% calculate error (make it slow)
        data1_corrected=gather(correctMotion_Wei_v2(data1,motion_current));
        diffError=gather(sum((data2-data1_corrected).^2,'all'));
        diffError=diffError/(x*y*z);
        penaltyRaw=motion_current(xG,yG,zG,:)*patchConnectNum-getNeiSum2(motion_current(xG,yG,zG,:),1)/8*patchConnectNum;
        penaltyRaw(:,:,:,3)=penaltyRaw(:,:,:,3)*zRatio;
        penaltyCorrected=sum(penaltyRaw.^2,4)*smoothPenalty;
        penaltyError=gather(sum(penaltyCorrected,'all'));
        penaltyError=penaltyError/(x*y*z);
        fprintf("Downsample:"+layer+"\tIter:"+iter+"\tstep:\t"+stepFactor+"\tError:\t"+(diffError+penaltyError)+"\tDiff:\t"+diffError+"\n");

        temp1(:,:,iter)=data1_tran(:,:,tempz);
        temp2(:,:,iter)=motion_update(:,:,tempz,1);
%         temp3(:,:,iter)=Ixt(:,:,tempz)./Ixx(:,:,tempz);
%         temp4(:,:,iter)=It(:,:,tempz);
        temp5(:,:,iter)=data1_corrected(:,:,tempz);
        temp6(:,:,iter)=motion_current(:,:,tempz,1);
        errorHistory(iter)=diffError+penaltyError;
% 
%         a=0;


    end

end

motion_current = gather(motion_current);

end