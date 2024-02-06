function [diffError,penaltyError]=calError(It,penaltyRaw,smoothPenaltySum,zRatio)

[x,y,z]=size(It);
diffError=gather(mean((It).^2,'all'));
penaltyRaw(:,:,:,3)=penaltyRaw(:,:,:,3)*zRatio;
penaltyCorrected=sum(penaltyRaw.^2,4)*smoothPenaltySum;
penaltyError=gather(sum(penaltyCorrected,'all'));
penaltyError=penaltyError/(x*y*z);

end