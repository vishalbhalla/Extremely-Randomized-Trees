function [structTree, X] = QuantisizeImagePair(imagePatch1, imagePatch2, boolAligned, structTree)
%QUANTISIZEIMAGEPAIR Summary of this function goes here
%   Detailed explanation goes here

nodeIdx = 1; % Root node of the tree.
while nodeIdx ~= 0
    threshold = structTree(nodeIdx).Threshold;
    feature = structTree(nodeIdx).Feature;
    parent = nodeIdx;
    if(imagePatch1(feature) > threshold && imagePatch2(feature) > threshold)
        nodeIdx = structTree(nodeIdx).RightNodeNo;
    else
        nodeIdx = structTree(nodeIdx).LeftNodeNo;
    end
    
    % Leaf Node
    % Add count to aligned or misaligned patch for this node in the tree data structure.
    if (nodeIdx == 0)
        if(boolAligned)
            structTree(parent).AlignedPatchIdx = structTree(parent).AlignedPatchIdx + 1;
        else
            structTree(parent).MisAlignedPatchIdx = structTree(parent).MisAlignedPatchIdx + 1;
        end
        structTree(parent).PatchPairNo = structTree(parent).PatchPairNo + 1;
        
        while (structTree(parent).LeftNodeNo ==0 && structTree(parent).RightNodeNo ==0)
            parent = parent - 1;
        end
        parent = parent + 1;

        % Now parent points to the first or the leftmost leaf. Return code vector.
        X = [];
        while (parent ~= 15+1)
            X = [X, structTree(parent).AlignedPatchIdx];
            parent = parent + 1;
        end
    end
    
end
end
