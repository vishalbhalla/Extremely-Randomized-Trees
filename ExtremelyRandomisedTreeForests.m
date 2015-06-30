
% Extremely Randomised Forests - Ensemble of Trees.
totalTrees = 10;
structForest = {};

for nt=1:totalTrees;
    structTree = constructTree();
    structForest = [structForest; structTree];
end


% patchSize = 15;
% totalPtsInPatch = patchSize*patchSize;
% imagePatch1 = [0:totalPtsInPatch-1]./255;
% imagePatch2 = [0:totalPtsInPatch-1]./255;
% imagePatch3 = [0:totalPtsInPatch-1]./1000;


% patchPairMatrix = [];
% patchPairMatrix = [patchPairMatrix ; imagePatch1,imagePatch2];
% patchPairMatrix = [patchPairMatrix ; imagePatch1,imagePatch3];
% patchPairMatrix = [patchPairMatrix ; imagePatch2,imagePatch3];
% alignedPatchPairVec = [];
% alignedPatchPairVec = [alignedPatchPairVec ; 1];
% alignedPatchPairVec = [alignedPatchPairVec ; 0];
% alignedPatchPairVec = [alignedPatchPairVec ; 0];
noPatches = 10;

% Code Vectors
X = [];

patchSize= 15;
totalPtsInPatch = patchSize*patchSize;
pixel_position_x = 72;
pixel_position_y = 72;
noOfSample = 20;
% imagePath1 = strcat('/Users/chingyukao/Documents/MATLAB/Multi-Modal-Similarity-till-08062015/Multi-Modal-Similarity/Dataset/','T1_11.TIFF')
% imagePath2 = strcat('/Users/chingyukao/Documents/MATLAB/Multi-Modal-Similarity-till-08062015/Multi-Modal-Similarity/Dataset/','T2_11.TIFF')

imagePath1 = strcat('E:\TUM\Courses\Summer Semester 2015\Machine Learning in Medical Imaging\Project\Multi-Modal-Similarity\Dataset\','T1_11.TIFF');
imagePath2 = strcat('E:\TUM\Courses\Summer Semester 2015\Machine Learning in Medical Imaging\Project\Multi-Modal-Similarity\Dataset\','T2_11.TIFF');


[similarPatches,disSimilarPatches] = extractPatchesPerPixel(imagePath1, imagePath2, pixel_position_x, pixel_position_y, patchSize, noOfSample);

similarPatches = reshape(cell2mat(similarPatches),[noPatches,2*patchSize*patchSize]); %convert cell to matrix
disSimilarPatches = reshape(cell2mat(disSimilarPatches),[noPatches,2*patchSize*patchSize]);%convert cell to matrix
patchPairMatrix = [similarPatches;disSimilarPatches];
boolAlignedInd = zeros(size(patchPairMatrix,1),1);
boolAlignedInd(1:10) = 1;
patchPairMatrix = [patchPairMatrix boolAlignedInd];


for np = 1:noPatches
%      imagePatch1 = patchPairMatrix(np,1:totalPtsInPatch);
%      imagePatch2 = patchPairMatrix(np,totalPtsInPatch+1:end-1);
     
     imagePatch1 = double(patchPairMatrix(np,1:totalPtsInPatch))./255;
     imagePatch2 = double( patchPairMatrix(np,totalPtsInPatch+1:end-1))./255;
     
     boolAligned = patchPairMatrix(end);
     X1 = [];
    for nt=1:totalTrees;
        structTree = structForest{nt};
        
        [structTree, x] = QuantisizeImagePair(imagePatch1, imagePatch2, boolAligned, structTree);
        structForest{nt} = structTree;
        X1 = [X1, x];
    end
    
    X = [X; X1];
    % Now iterate over the leaves of each tree in the Forest for this particular patch pair to find the vector X.
end

% After finding vector X for each patch pair, use it to define how significant the leaf was.

