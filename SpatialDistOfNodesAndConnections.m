function [LLC,RRC,LRC,LN,RN]=SpatialDistOfNodesAndConnections(mat)
% this function evaluate the spatial distribution of the significant nodes and edges between hemispheres
%Inputs:  -mat: the matrix of significant connections of dimension [ROI*ROI]:
%              contains 1 if the connection is significant and 0 otherwise
%Outputs: -LLC: percentage of the connections within the left hemisphere
%         -RRC: percentage of the connections within the right hemisphere
%         -LRC: percentage of the interhemisphere connections
%         -LN: percentage of nodes within the left hemisphere
%         -RN: percentage of nodes within the right hemisphere

% This code was originally developped by Sahar Yassine
% contact: saharyassine94@gmail.com
%
%%
LLC=0;LRC=0;RRC=0;LN=0;RN=0;
allConn=sum(sum(mat));
allNodes=[];

%this code was built based on the Brainnetome Atlas where:
%the nodes with odd values are those in the left hemisphere
%the nodes with even values are those in the right hemisphere

for i=1:size(mat,1)
    for j=i+1:size(mat,2)
        if(mat(i,j)==1)
            allNodes=[allNodes;i;j];
            if(rem(i,2)==1 && rem(j,2)==1)
                LLC=LLC+1;
            elseif(rem(i,2)==0 && rem(j,2)==0)
                RRC=RRC+1;
            else
                LRC=LRC+1;
            end
        end
    end
end
allNodes=unique(allNodes);
for i=1:length(allNodes)
    if(rem(allNodes(i),2)==1)
        LN=LN+1;
    else
        RN=RN+1;
    end
end
LLC=(LLC*100)/allConn;
RRC=(RRC*100)/allConn;
LRC=(LRC*100)/allConn;
LN=(LN*100)/length(allNodes);
RN=(RN*100)/length(allNodes);

end
