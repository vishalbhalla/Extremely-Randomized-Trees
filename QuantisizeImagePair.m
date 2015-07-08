function [structTree, X] = QuantisizeImagePair(imagePatch1, imagePatch2, boolAligned, structTree, treeDepth, lastNodeNo)
%QUANTISIZEIMAGEPAIR Summary of this function goes here
%   Detailed explanation goes here
patchAtLeaf = 0;
nodeIdx = 1; % Root node of the tree.

leafStart = 2^treeDepth; % Leaves start here in the tree.
X = [];
% The leaf was removed and hence the patch can't be traversed further in the tree.
%while nodeIdx ~= 0
while nodeIdx > 0
    threshold = structTree(nodeIdx).Threshold;
    feature = structTree(nodeIdx).Feature;
    parent = nodeIdx;
    if(imagePatch1(feature) > threshold && imagePatch2(feature) > threshold)
        nodeIdx = structTree(nodeIdx).RightNodeNo;
    else
        nodeIdx = structTree(nodeIdx).LeftNodeNo;
    end
    
    % Leaf Node where the patch currently lies is set to 1.
    patchAtLeaf = parent;
    % Add weight of the aligned or misaligned patch for this node in the tree data structure.
    %if (nodeIdx == 0)
    if (nodeIdx <= 0)
        if(boolAligned)
            structTree(parent).AlignedPatchIdx = 1;
            structTree(parent).WeightAlignedPatchIdx = structTree(parent).WeightAlignedPatchIdx + 1;
        else
            structTree(parent).MisAlignedPatchIdx = 1;
            structTree(parent).WeightMisAlignedPatchIdx = structTree(parent).WeightMisAlignedPatchIdx + 1;
        end

        parent = leafStart;

        % Now parent points to the first or the leftmost leaf. Return code vector.
        %X = [];
        while (parent <= lastNodeNo)
            if(structTree(parent).LeftNodeNo~=-1 && structTree(parent).RightNodeNo~=-1)
                if(parent ~= patchAtLeaf)
                    X = [X, 0];
                else
                    X = [X, 1];
                end
            end
            parent = parent + 1;
        end
    end
    
end
end
