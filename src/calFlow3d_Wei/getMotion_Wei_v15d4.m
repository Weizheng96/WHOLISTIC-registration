function motion_current=getMotion_Wei_v15d4(dat_mov,dat_ref,smoothPenalty_raw,option)
%% v15d4: always based on original coordinates

%% parameters need to adjust
layer_num=option.larer;              % pyramid layer num
iterNum=option.iter;
r=option.r;
pad_size = [20 20 2]; 
step=1;
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
    %%
    data1_pad = padarray(data1,pad_size,'replicate');

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
        x_bias = reshape(motion_current(:,:,:,1),[1 x*y*z]);
        y_bias = reshape(motion_current(:,:,:,2),[1 x*y*z]);
        z_bias = reshape(motion_current(:,:,:,3),[1 x*y*z]);
       
        % get tranformed data
        x_new = x_ind + x_bias;
        y_new = y_ind + y_bias;
        z_new = z_ind + z_bias;
       
        data1_x_incre = interp3(data1_pad,y_new+pad_size(2),x_new+step+pad_size(1),z_new+pad_size(3));
        data1_x_decre = interp3(data1_pad,y_new+pad_size(2),x_new-step+pad_size(1),z_new+pad_size(3));
        Ix = (data1_x_incre - data1_x_decre)/(2*step);
        clear data1_x_incre data1_x_decre
    
        data1_y_incre = interp3(data1_pad,y_new+step+pad_size(2),x_new+pad_size(1),z_new+pad_size(3));
        data1_y_decre = interp3(data1_pad,y_new-step+pad_size(2),x_new+pad_size(1),z_new+pad_size(3));
        Iy = (data1_y_incre - data1_y_decre)/(2*step);
        clear data1_y_incre data1_y_decre  
    
        data1_z_incre = interp3(data1_pad,y_new+pad_size(2),x_new+pad_size(1),z_new+step+pad_size(3));
        data1_z_decre = interp3(data1_pad,y_new+pad_size(2),x_new+pad_size(1),z_new-step+pad_size(3));
        Iz = (data1_z_incre - data1_z_decre)/(2*step);
        clear data1_z_incre data1_z_decre    
       
        Ix = reshape(Ix, [x y z]);
        Iy = reshape(Iy, [x y z]);
        Iz = reshape(Iz, [x y z]);

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