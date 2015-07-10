function [XTest, meanTransSimilarity, testGroundTruthSimilarity] = SimilarityTestImage(base_T1, patchSize, noPatches, noOfPosPatches, noOfSample, treeDepth, noTreeNodes, totalTreesInForest, structForest, Weights, boolTranslationRotation, transform)

patchPairMatrix = [];
testGroundTruthSimilarity = [];  

for i = 10:12
    imagePath = strcat(base_T1,num2str(i),'.TIFF');
    [originalImage, transformedImage] = ImageTransformations(imagePath, transform, boolTranslationRotation);
    for p = 1:noOfPosPatches
        pixel_position_x = randi(256);
        pixel_position_y = randi(256);
        [similarPatches,disSimilarPatches] = extractPatchesPerPixel(originalImage, transformedImage, pixel_position_x, pixel_position_y, patchSize, noOfSample);
        similarPatches = reshape(cell2mat(similarPatches),[1,2*patchSize*patchSize]); %convert cell to matrix
        disSimilarPatches = reshape(cell2mat(disSimilarPatches),[noPatches,2*patchSize*patchSize]);%convert cell to matrix
        temp = [similarPatches; disSimilarPatches];

        boolAlignedInd = zeros(noOfSample,1);
        if(transform == 0)
            boolAlignedInd(1) = 1;
        end
        
        temp = [temp boolAlignedInd];
        testGroundTruthSimilarity = [testGroundTruthSimilarity; boolAlignedInd];
        patchPairMatrix = [patchPairMatrix; temp];
    end
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

predTransSimilarity = XTest * Weights';
% Normalise over the number of trees such that the final similarity value is between 0 and 1.
predNormTransSimilarity = predTransSimilarity./(2^treeDepth);
meanTransSimilarity = mean(predNormTransSimilarity);

end

