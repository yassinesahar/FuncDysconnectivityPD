function NI=Calculate_NI(maskMatrix,plvs)
%this function compute the network index of the significant connections
%Inputs:  -maskMatrix: the binary matrix of significant connections of dimesnion [ROI*ROI]contains 1 for significant connections and 0 otherwise
%         -plvs: the connectivity matrices of the subjects of dimension[ROI,ROI,NSUB] 
%                where ROI is the number of regions of interest and NSub is the number of participants
%
%Outputs: -NI: the network index as the mean weight of the significant connections (the value should be between 0 and 1), dimension [NSub,1]
%
% This code was originally developped by Sahar Yassine
% contact: saharyassine94@gmail.com
%          

%%
Nsub=size(plvs,3);
NI=zeros(Nsub,1);
nEdges=sum(sum(maskMatrix));

for i=1:Nsub
    mat=squeeze(plvs(:,:,i)).*maskMatrix;
    NI(i,1)=sum(sum(mat));
end
NI=NI./nEdges;

end
