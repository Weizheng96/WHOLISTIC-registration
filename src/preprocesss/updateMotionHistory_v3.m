function [motion_history,BestMotion]=updateMotionHistory_v3(motion_current_raw,motion_history)

% motion_history=gpuArray(motion_history);
%% resize motion
[x,y,z,~,~]=size(motion_history);
motion_current=zeros(x,y,z,2,"single");

motion_current(:,:,:,1)=imresize3(motion_current_raw(:,:,:,1),[x,y,z]);
motion_current(:,:,:,2)=imresize3(motion_current_raw(:,:,:,2),[x,y,z]);

%% update
motion_history(:,:,:,:,1:end-1)=motion_history(:,:,:,:,2:end);
motion_history(:,:,:,:,end)=motion_current;

motion_median=median(motion_history,5);

errorLst=squeeze(mean((motion_history-motion_median).^2,[1 2 3 4]));
[~,I]=min(errorLst);
BestMotion=motion_history(:,:,:,:,I);
%%
% motion_history=gather(motion_history);
% BestMotion=gather(BestMotion);

end