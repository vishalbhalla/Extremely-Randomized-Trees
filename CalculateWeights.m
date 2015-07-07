function weight = CalculateWeights(structTree, treeDepth, noTreeNodes)
%CALCULATEWEIGHTS
patchAtLeaf = 0;
leafStart = 2^treeDepth;
nodeIdx = leafStart; % Leaves start here in the tree.

w = [];
while (nodeIdx <= noTreeNodes)
    totalAlignedMisAlignedPatches = structTree(nodeIdx).WeightAlignedPatchIdx + structTree(nodeIdx).WeightMisAlignedPatchIdx;
    % Remove leaves which have no aligned and misaligned patches (i.e. they
    % have no significance.)
    if(structTree(nodeIdx).WeightAlignedPatchIdx == 0)
        if(totalAlignedMisAlignedPatches == 0)
            w = [w,0];
        else
            w = [w,-1];
        end
        %w = [w,0];
    else
        w = [w, structTree(nodeIdx).WeightAlignedPatchIdx/totalAlignedMisAlignedPatches];
    end
    nodeIdx = nodeIdx + 1;
end

weight = w;
end
