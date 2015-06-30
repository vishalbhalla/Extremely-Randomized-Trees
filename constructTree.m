function structTree = constructTree()
%CONSTRUCTTREE Summary of this function goes here
%   Detailed explanation goes here

structTree = [];
NodeNo = 'NodeNo';
LeftNodeNo = 'LeftNodeNo';
RightNodeNo = 'RightNodeNo';
Threshold = 'Threshold';
Feature = 'Feature';
PatchPairNo = 'PatchPairNo';
AlignedPatchIdx = 'AlignedPatchIdx';
MisAlignedPatchIdx = 'MisAlignedPatchIdx';

parent = 1;
s = struct(NodeNo,1,LeftNodeNo,parent+1,RightNodeNo,parent+2,PatchPairNo,0,Threshold,rand(1),Feature,randi(225),AlignedPatchIdx,0,MisAlignedPatchIdx,0);
structTree = [structTree; s];

intNodeNo = 2;

d = 3; % Depth of the tree
n = 2^(d+1) -1; % Total No. of nodes.
%noChildNodes = 2;
for i = 2:n
    parent = i;
    %for j=1:noChildNodes
        intNodeNo = parent; 
        threshold = rand(1);
        feature = randi(225);
        intPatchPairNo = i;
        intAlignedPatchIdx = i;
        valNodeNo = intNodeNo;
        
        if(2*intNodeNo>n)
            valLeftNodeNo = 0;
            valRightNodeNo = 0;
        else
            valLeftNodeNo = 2*intNodeNo;
            valRightNodeNo = 2*intNodeNo +1;
        end
        valPatchPairNo = 0;
        valAlignedPatchIdx = 0;
        valMisAlignedPatchIdx = 0;

        s = struct(NodeNo,valNodeNo,LeftNodeNo,valLeftNodeNo,RightNodeNo,valRightNodeNo,PatchPairNo,0,Threshold,threshold,Feature,feature,AlignedPatchIdx,0,MisAlignedPatchIdx,0);
        structTree = [structTree; s];
    %end
end

end

