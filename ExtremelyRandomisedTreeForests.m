
%% Extremely Randomised Forests - Ensemble of Trees.

% Pick up the parameters from the config file.
[patchSize, treeDepth, noTreeNodes, noOfPosPatches, noPatches, noOfSample, totalTreesInForest, trainingDataPath, testDataPath] = TuningParametersConfig();


%% Training
structForest = {};

for nt=1:totalTreesInForest;
    structTree = constructTree(noTreeNodes, patchSize);
    structForest = [structForest; structTree];
end

%noPatches = 20;

% Code Vectors
X = [];

%patchSize= 15;
totalPtsInPatch = patchSize*patchSize;
pixel_position_x = randi(256);
pixel_position_y = randi(256);
%noOfSample = noPatches+1;

base_T1 = strcat(trainingDataPath, 'T1_');
base_T2 = strcat(trainingDataPath, 'T2_');

% base_T1 = 'E:\TUM\Courses\Summer Semester 2015\Machine Learning in Medical Imaging\Project\Extremely Randomized Trees\Dataset\T1_';
% base_T2 = 'E:\TUM\Courses\Summer Semester 2015\Machine Learning in Medical Imaging\Project\Extremely Randomized Trees\Dataset\T2_';

patchPairMatrix = [];
for i = 1:12
    %path = strcat(base,num2str(i),'.TIFF');
    if( i ~= 8)
    if(i<10)
        j = strcat('0',num2str(i));
    end
        
    imagePath1 = strcat(base_T1,num2str(j),'.TIFF');
    imagePath2 = strcat(base_T2,num2str(j),'.TIFF');
    

    %noOfPosPatches = 10;

for p = 1:noOfPosPatches
    pixel_position_x = randi(256);
    pixel_position_y = randi(256);
    [similarPatches,disSimilarPatches] = extractPatchesPerPixel(imagePath1, imagePath2, pixel_position_x, pixel_position_y, patchSize, noOfSample);
    similarPatches = reshape(cell2mat(similarPatches),[1,2*patchSize*patchSize]); %convert cell to matrix
    disSimilarPatches = reshape(cell2mat(disSimilarPatches),[noPatches,2*patchSize*patchSize]);%convert cell to matrix
    temp = [similarPatches; disSimilarPatches];
    
    boolAlignedInd = zeros(noOfSample,1);
    boolAlignedInd(1) = 1;
    temp = [temp boolAlignedInd];
    patchPairMatrix = [patchPairMatrix; temp];
end
    end
end


%% the following code for 10 aligned patches, and each have 10 misaligned pathches(totally 100 misaligned patches accordingly).

boolAlignedInd = patchPairMatrix(:,end);

for np = 1:noOfSample*noOfPosPatches
     imagePatch1 = double(patchPairMatrix(np,1:totalPtsInPatch))./255;
     imagePatch2 = double(patchPairMatrix(np,totalPtsInPatch+1:end-1))./255;
     boolAligned = boolAlignedInd(np);
     XCodeVecPatchPair = [] ;
    for nt=1:totalTreesInForest;
        structTree = structForest{nt};
        [structTree, x] = QuantisizeImagePair(imagePatch1, imagePatch2, boolAligned, structTree, treeDepth, noTreeNodes);
        structForest{nt} = structTree;
        XCodeVecPatchPair = [XCodeVecPatchPair, x];
    end
    
    X = [X; XCodeVecPatchPair];
    % Now iterate over the leaves of each tree in the Forest for this particular patch pair to find the vector X.
end

% After finding vector X for each patch pair, use it to define how significant the leaf was.
% Now calculate the weights for each leaf in every tree of the forest.
Weights = [];
for nt=1:totalTreesInForest;
    structTree = structForest{nt};
    w = CalculateWeights(structTree, treeDepth, noTreeNodes);
    Weights = [Weights, w];
end


%% Test
%Use the weights to define the similarity measure of the test data set.

patchPairMatrix = [];
testGroundTruthSimilarity = [];
for i = 10:12
    
    imagePath1 = strcat(base_T1,num2str(j),'.TIFF');
    imagePath2 = strcat(base_T2,num2str(j),'.TIFF');

    for p = 1:noOfPosPatches
        pixel_position_x = randi(256);
        pixel_position_y = randi(256);
        [similarPatches,disSimilarPatches] = extractPatchesPerPixel(imagePath1, imagePath2, pixel_position_x, pixel_position_y, patchSize, noOfSample);
        similarPatches = reshape(cell2mat(similarPatches),[1,2*patchSize*patchSize]); %convert cell to matrix
        disSimilarPatches = reshape(cell2mat(disSimilarPatches),[noPatches,2*patchSize*patchSize]);%convert cell to matrix
        temp = [similarPatches; disSimilarPatches];

        boolAlignedInd = zeros(noOfSample,1);
        boolAlignedInd(1) = 1;
        temp = [temp boolAlignedInd];
        testGroundTruthSimilarity = [testGroundTruthSimilarity; boolAlignedInd];
        patchPairMatrix = [patchPairMatrix; temp];
    end
end

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
        structForest{nt} = structTree;
        XTestCodeVecPatchPair = [XTestCodeVecPatchPair, x];
    end
    
    XTest = [XTest; XTestCodeVecPatchPair];
    % Now iterate over the leaves of each tree in the Forest for this particular patch pair to find the vector X.
end


predictedSimilarity = XTest * Weights';

% Normalise over the number of trees such that the final similarity value is between 0 and 1.
predNormalizedSimilarity = predictedSimilarity./(2^treeDepth);
predNormalizedSimilarity = (predNormalizedSimilarity + 1)./2;

%% Evaluation - Performance Measures!

%% =========== Classification - Confusion Matrix =============
% Define the vectors for the ground truth and the predicted class for each sample.
groundTruth = testGroundTruthSimilarity; %[1,0,0,1,0,0,1,1,0,1,0,0,1,1,0,0,1,1,0,1,0,1]';
Predictions = predNormalizedSimilarity; %predictedSimilarity; %[0.6,0.2,0.3,0.5,0.9,0.8,0.6,0.3,0.1,0.2,0.1,0.5,0.8,0.1,0.3,0.7,0.8,0.2,0.4,0.4,0.5,0.4]';


thresholdVec = [0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1];
totalThresholds = size(thresholdVec,2);

lstconfMat2by2 = {};
sensitivityVec = zeros(1, totalThresholds);
specificityVec = zeros(1, totalThresholds);
PPVVec = zeros(1, totalThresholds);
NPVVec = zeros(1, totalThresholds);
accuracyVec = zeros(1, totalThresholds);
F1_MeasureVec = zeros(1, totalThresholds);

for t=1:totalThresholds
    
    % =========== Part a: Threshold Confusion Matrix =============
    % The function threshold_confusion_matrix expects a vector containing the ground truth and
    % a vector of containing the predicted probabilities for each sample.
    % For each unique threshold the function should return a 2 × 2 confusion matrix.

    confMat2by2 = threshold_confusion_matrix(groundTruth, Predictions, thresholdVec(t));
    lstconfMat2by2 = [lstconfMat2by2 ; confMat2by2];
    
    % =========== Part b: Performance Measures =============
    % For any number of classes calculate the following 6 measures based on a confusion matrix:
    % Sensitivity, specificity, positive predictive value, negative predictive value, accuracy, and F1 measure.
    [sensitivityVec(t), specificityVec(t), PPVVec(t), NPVVec(t), accuracyVec(t), F1_MeasureVec(t)] = performanceMeasures(lstconfMat2by2{t});
end


%% =========== ROC and Precision-Recall Curve =============
% For a binary classifier - Let the classes be represented by 0 and 1.

% Part a. ROC
% False positive rate = 1 - Specificity
figure(1);
plot(1 - specificityVec, sensitivityVec);
title('ROC');

% Part b. Precision-Recall curve
% Precision = Positive predictive value (PPV)
% Recall = Sensitivity !!
figure(2);
plot(PPVVec, sensitivityVec);
title('Precision-Recall curve');

