function [diffError,penaltyError]=calError_v2(It,penaltyRaw,smoothPenaltySum)

[x,y,z]=size(It);
diffError=gather(mean((It).^2,'all'));
penaltyCorrected=sum(penaltyRaw.^2,4)*smoothPenaltySum;
penaltyError=gather(sum(penaltyCorrected,'all'));
penaltyError=penaltyError/(x*y*z);

end