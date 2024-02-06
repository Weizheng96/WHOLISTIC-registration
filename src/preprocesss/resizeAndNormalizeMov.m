function [dat_mov_normalized,dat_mov]=resizeAndNormalizeMov(dat_mov_Raw,muRef,sigmaRef,Z_ref,option)

mu=mean(dat_mov_Raw,'all');sigma=std(dat_mov_Raw,0,'all');
sigmaRatio=sigmaRef/sigma;

dat_mov=resizeMov(dat_mov_Raw,Z_ref,option);

dat_mov_normalized=dat_mov.*sigmaRatio+(muRef-mu*sigmaRatio);

end