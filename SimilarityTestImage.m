function [XTest, testGroundTruthSimilarity] = SimilarityTestImage(base_T1, patchSize, noPatches, noOfPosPatches, noOfSample, treeDepth, noTreeNodes, totalTreesInForest, structForest, boolTranslationRotation, transform)

patchPairMatrix = [];
testGroundTruthSimilarity = [];  

for i = 10:12
    imagePath = strcat(base_T1,num2str(i),'.TIFF');
    [originalImage, transformedImage] = ImageTransformations(imagePath, transform, boolTranslationRotation);

    similarPosPatches = extractSimilarPosPatches(originalImage, transformedImage, patchSize, noOfSample);
    %similarPatches = reshape(cell2mat(similarPosPatches),[1,2*patchSize*patchSize]); %convert cell to matrix
    temp = similarPosPatches;

    boolAlignedInd = zeros(noOfSample,1);

    if(size(transform) == 1)
         boolAlignedInd = ones(noOfSample,1);
    elseif (transform(1) == 0 && transform(2) == 0)
            boolAlignedInd = ones(noOfSample,1);
    end
    
    temp = [temp boolAlignedInd];
    testGroundTruthSimilarity = [testGroundTruthSimilarity; boolAlignedInd];
    patchPairMatrix = [patchPairMatrix; temp];

end

totalPtsInPatch = patchSize * patchSize;
boolAlignedInd = patchPairMatrix(:,end);
XTest = [];
noOfTestSample = size(patchPairMatrix,1);
for np = 1:noOfTestSample
    imagePatch1 = double(patchPairMatrix(np,1:totalPtsInPatch))./255;
    imagePatch2 = double(patchPairMatrix(np,totalPtsInPatch+1:end-1))./255;
    boolAligned = boolAlignedInd(np);
    XTestCodeVecPatchPair = [] ;
    for nt=1:totalTreesInForest
        structTree = structForest{nt};
        [structTree, x] = QuantisizeImagePair(imagePatch1, imagePatch2, boolAligned, structTree, treeDepth, noTreeNodes);
        %structForest{nt} = structTree;
        XTestCodeVecPatchPair = [XTestCodeVecPatchPair, x];
    end
    
    XTest = [XTest; XTestCodeVecPatchPair];
    % Now iterate over the leaves of each tree in the Forest for this particular patch pair to find the vector X.
end

end

