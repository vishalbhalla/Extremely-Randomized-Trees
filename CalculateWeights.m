function weight = CalculateWeights(structTree, treeDepth, noTreeNodes)
%CALCULATEWEIGHTS
patchAtLeaf = 0;
leafStart = 2^treeDepth;
nodeIdx = leafStart; % Leaves start here in the tree.

w = [];
while (nodeIdx <= noTreeNodes)
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
