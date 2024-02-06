function motion_current=getMotion_Wei_v19d1(dat_mov,dat_ref,smoothPenalty_raw,option)
%% v19d1: new motion range and Nesterov's momentum

%% parameters need to adjust
layer_num=option.larer;              % pyramid layer num
iterNum=option.iter;
r=option.r;
zRatio_raw=option.zRatio;
decayRate=option.MomentumDecayRate;
%% for test
tempz=option.tempz;

%% parameters don't need to adjust
SZ=size(dat_mov);
movRange=5;
%% multi-scale loop
for layer = layer_num:-1:0

    %% dowmsample for current scale
    smoothPenalty=smoothPenalty_raw;
    data1 = gpuArray(imresize3(dat_mov, [round(SZ(1:2)/2^layer) SZ(3)]));
    data2 = gpuArray(imresize3(dat_ref, [round(SZ(1:2)/2^layer) SZ(3)]));
    [x,y,z] = size(data1);

    zRatio=zRatio_raw/2^layer;
    
    
    %% initilize the motion of each layer
    if layer == layer_num
        if isfield(option,'motion') && ~isempty(option.motion)
            motion_current = gpuArray(zeros(x,y,z,3));
            motion_current(:,:,:,1)=imresize3(option.motion(:,:,:,1),[x,y,z])/(SZ(1)/x);
            motion_current(:,:,:,2)=imresize3(option.motion(:,:,:,2),[x,y,z])/(SZ(2)/y);
            motion_current(:,:,:,3)=imresize3(option.motion(:,:,:,3),[x,y,z])/(SZ(3)/z);
        else
            motion_current = gpuArray(zeros(x,y,z,3));
        end
    else
        motion_current_temp=gather(motion_current);
        motion_current=zeros(x,y,z,3);
        motion_current(:,:,:,1) = imresize3(motion_current_temp(:,:,:,1), [x,y,z],"linear")*2;
        motion_current(:,:,:,2) = imresize3(motion_current_temp(:,:,:,2), [x,y,z],"linear")*2;
        motion_current(:,:,:,3) = imresize3(motion_current_temp(:,:,:,3), [x,y,z],"linear");
        motion_current=gpuArray(motion_current);
    end
    
    [x_ind,y_ind,z_ind] = ind2sub(size(data1),1:x*y*z);
    %% initialize momentum
    motion_mmt=gpuArray(zeros(x,y,z,3));

    %% for test
    temp1=zeros(x,y,iterNum);temp2=zeros(x,y,iterNum);
    temp3=zeros(x,y,iterNum);temp4=zeros(x,y,iterNum);
    temp5=zeros(x,y,iterNum);temp6=zeros(x,y,iterNum);
    errorHistory=zeros(iterNum,1);
    intErrorHistory=zeros(iterNum,1);

    %% update motion loop
%     fprintf("\nDownsample:"+layer+"\n");
    for iter = 1:iterNum
        %% get estimated future motion
        motion_future=motion_current+motion_mmt;
        %% get corrected data
        data1_tran=correctMotion_Wei_v2(data1,motion_future);
       
        %% get spatial gradient
        [Ix,Iy,Iz]=getSpatialGradientInOrg_Wei(data1,motion_future);

        %% get temporal difference
        It = data2-data1_tran;
        It = imfilter(It,ones(3)/9,'replicate','same','corr');
    
        %% get motion update of control points
        AverageFilter=ones(r*2+1);
        xG=r+1:2*r+1:x;yG=r+1:2*r+1:y;zG=1:z;

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
        smoothPenaltySum=smoothPenalty*patchConnectNum;
        neiSum=smoothPenaltySum*getNeiDiff(motion_future(xG,yG,zG,:),1);

        motion_update=getFlow3_withPenalty4(Ixx,Ixy,Ixz,Iyy,Iyz,Izz,Ixt,Iyt,Izt,smoothPenaltySum,neiSum,zRatio);

        motion_update=motion_update+motion_mmt(xG,yG,zG);
        %% the control points can't move far away
        motion_update_dist=sqrt(sum((motion_update.^reshape([1 1 27],[1 1 1 3])).^2,4));
        motion_update_dist=max(motion_update_dist./movRange,1);
        motion_update=motion_update./motion_update_dist;
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
        %% update the momentum
        motion_mmt=motion_update*decayRate;
        %% calculate error (make it slow)
        data1_corrected=gather(correctMotion_Wei_v2(data1,motion_current));
        diffError=gather(mean((data2-data1_corrected).^2,'all'));
        penaltyRaw=getNeiDiff(motion_current(xG,yG,zG,:),1);
        penaltyRaw(:,:,:,3)=penaltyRaw(:,:,:,3)*zRatio;
        penaltyCorrected=sum(penaltyRaw.^2,4)*smoothPenaltySum;
        penaltyError=gather(sum(penaltyCorrected,'all'));
        penaltyError=penaltyError/(x*y*z);
        fprintf("Downsample:"+layer+"\tIter:"+iter+"\tError:\t"+(diffError+penaltyError)+"\tDiff:\t"+diffError+"\n");

        temp1(:,:,iter)=data1_tran(:,:,tempz);
        temp2(:,:,iter)=motion_update(:,:,tempz,1);
        temp3(:,:,iter)=motion_current(:,:,tempz,1);
        temp4(:,:,iter)=motion_current(:,:,tempz,2);
        temp5(:,:,iter)=data1_corrected(:,:,tempz);
        temp6(:,:,iter)=motion_current(:,:,tempz,3);
        errorHistory(iter)=diffError+penaltyError;
        intErrorHistory(iter)=diffError;

        if iter == iterNum
            if layer == 0
                b=0;
            end
            a=0;
        end

    end

end

motion_current = gather(motion_current);

end