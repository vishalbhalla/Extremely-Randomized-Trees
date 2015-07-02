function weight = CalculateWeights(structTree, treeDepth, noTreeNodes)
%CALCULATEWEIGHTS Summary of this function goes here
%QUANTISIZEIMAGEPAIR Summary of this function goes here
%   Detailed explanation goes here
patchAtLeaf = 0;
nodeIdx = 1; % Root node of the tree.
leafStart = 2^(treeDepth-1) + 1;
while (nodeIdx ~= leafStart)
    RightNodeNo = structTree(nodeIdx).RightNodeNo;
    LeftNodeNo = structTree(nodeIdx).LeftNodeNo;
    if(LeftNodeNo ~=0 &&  RightNodeNo ~= 0)
        nodeIdx = nodeIdx + 1;
    end
end

w = [];
while (nodeIdx ~= (noTreeNodes + 1))
    totalAlignedMisAlignedPatches = structTree(nodeIdx).WeightAlignedPatchIdx + structTree(nodeIdx).WeightMisAlignedPatchIdx;
    if(totalAlignedMisAlignedPatches == 0)
        w = [w,0];
    else
        w = [w, structTree(nodeIdx).WeightAlignedPatchIdx/totalAlignedMisAlignedPatches];
    end
    nodeIdx = nodeIdx + 1;
end

weight = w;
end

