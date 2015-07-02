function weight = CalculateWeights(structTree)
%CALCULATEWEIGHTS Summary of this function goes here
%QUANTISIZEIMAGEPAIR Summary of this function goes here
%   Detailed explanation goes here
patchAtLeaf = 0;
nodeIdx = 1; % Root node of the tree.
while (nodeIdx ~= 8)
    RightNodeNo = structTree(nodeIdx).RightNodeNo;
    LeftNodeNo = structTree(nodeIdx).LeftNodeNo;
    if(LeftNodeNo ~=0 &&  RightNodeNo ~= 0)
        nodeIdx = nodeIdx + 1;
    end
end

w = [];
while (nodeIdx ~= 15+1)
    w = [w, structTree(nodeIdx).WeightAlignedPatchIdx/(structTree(nodeIdx).WeightAlignedPatchIdx + structTree(nodeIdx).WeightMisAlignedPatchIdx)];
    nodeIdx = nodeIdx + 1;
end

weight = w;
end

