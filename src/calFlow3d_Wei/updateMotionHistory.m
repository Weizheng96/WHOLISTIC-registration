function [motion_history,BestMotion]=updateMotionHistory(motion_current,motion_history)

motion_history(:,:,:,:,1:end-1)=motion_history(:,:,:,:,2:end);
motion_history(:,:,:,:,end)=motion_current;

if nargout==2
    motion_median=median(motion_history,5);
    errorLst=squeeze(mean((motion_history-motion_median).^2,[1 2 3 4]));
    [~,I]=min(errorLst);
    BestMotion=motion_history(:,:,:,:,I);
end

end