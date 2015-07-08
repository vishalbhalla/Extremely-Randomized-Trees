function [weight, structTree] = CalculateWeightsTest(structTree, treeDepth, noTreeNodes)
%CALCULATEWEIGHTS
patchAtLeaf = 0;
leafStart = 2^treeDepth;
nodeIdx = leafStart; % Leaves start here in the tree.

w = [];
while (nodeIdx <= noTreeNodes)
    totalAlignedMisAlignedPatches = structTree(nodeIdx).WeightAlignedPatchIdx + structTree(nodeIdx).WeightMisAlignedPatchIdx;
    if(structTree(nodeIdx).WeightAlignedPatchIdx == 0)
        if(totalAlignedMisAlignedPatches == 0)
            % Remove leaves which have no aligned and misaligned patches as they have no significance.
            structTree(nodeIdx).LeftNodeNo = -1;
            structTree(nodeIdx).RightNodeNo = -1;
            % Also they will have no weight associated with it.
        else
            % Contains Misaligned patches only so assign similarity to 0.
            w = [w,0];
        end
        %w = [w,0];
    else
        w = [w, structTree(nodeIdx).WeightAlignedPatchIdx/totalAlignedMisAlignedPatches];
    end
    nodeIdx = nodeIdx + 1;
end

weight = w;
end
