
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

patchPairMatrix = [];
for i = 1:12
    %path = strcat(base,num2str(i),'.TIFF');
    if( i ~= 8)
    if(i<10)
        j = strcat('0',num2str(i));
    end
        
    imagePath1 = strcat(base_T1,num2str(j),'.TIFF');
    imagePath2 = strcat(base_T2,num2str(j),'.TIFF');
    
    ImageModality1 = imread(imagePath1);
    ImageModality2 = imread(imagePath2);

    %noOfPosPatches = 10;

for p = 1:noOfPosPatches
    pixel_position_x = randi(256);
    pixel_position_y = randi(256);
    %[similarPatches,disSimilarPatches] = extractPatchesPerPixel(imagePath1, imagePath2, pixel_position_x, pixel_position_y, patchSize, noOfSample);
    [similarPatches,disSimilarPatches] = extractPatchesPerPixel(ImageModality1, ImageModality2, pixel_position_x, pixel_position_y, patchSize, noOfSample);
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
    [w, structRemovedLeavesTree] = CalculateWeightsTest(structTree, treeDepth, noTreeNodes);
    Weights = [Weights, w];
    structForest{nt} = structRemovedLeavesTree;
end


%% Test
% Use the weights to define the similarity measure of the test data set.

XTest = [];
TestGroundTruthSimilarity = [];

% Perform Transformations on Image for Testing.
%translations = [[-80,-10];[-70,20];[-60,40];[-50,0];[-40,-40];[-30,-10];[-20,20];[-10,70];[0,0];[10,20];[20,-20];[30,-70];[40,-10];[50,20];[60,-30];[70,40]];
translations = [[-40,-40];[40,40];[-40,40];[40,-40];[0,0];[-20,-20];[20,20];[-20,20];[20,-20];[-10,-10];[10,10];[-10,10];[10,-10];[-80,-10];[-70,20];[-60,40];[-50,0];[-40,-40];[-30,-10];[10,20];[30,-70];[40,-10];[50,20];[60,-30];[70,40]];
totalTranlations = size(translations,1);

rotations = [-100;-90;-75;-60;-45;-30;-15;0;5;15;30;45;60;75;90;100];
totalRotations = size(rotations,1);

translationSimilarity = [];
rotationSimilarity = [];

for t=1:totalTranlations
    % Translation of Image
    boolTranslationRotation = true;
    [XTransTest, transGroundTruthSimilarity] = SimilarityTestImage(base_T1, patchSize, noPatches, noOfPosPatches, noOfSample, treeDepth, noTreeNodes, totalTreesInForest, structForest, boolTranslationRotation, translations(t,:));
    XTest = [XTest; XTransTest];
    TestGroundTruthSimilarity = [TestGroundTruthSimilarity; transGroundTruthSimilarity];
    
    predTransSimilarity = XTransTest * Weights';
    % Normalise over the number of trees such that the final similarity value is between 0 and 1.
    predNormTransSimilarity = predTransSimilarity./(2^treeDepth);
    meanTransSimilarity = mean(predNormTransSimilarity);
    translationSimilarity = [translationSimilarity; meanTransSimilarity];
end
    
for t=1:totalRotations    
    % Rotation of Image
    boolTranslationRotation = false;
    [XRotTest, rotGroundTruthSimilarity] = SimilarityTestImage(base_T1, patchSize, noPatches, noOfPosPatches, noOfSample, treeDepth, noTreeNodes, totalTreesInForest, structForest, boolTranslationRotation, rotations(t));
    XTest = [XTest; XRotTest];
    TestGroundTruthSimilarity = [TestGroundTruthSimilarity; rotGroundTruthSimilarity];
    
    predRotSimilarity = XRotTest * Weights';
    % Normalise over the number of trees such that the final similarity value is between 0 and 1.
    predNormRotSimilarity = predRotSimilarity./(2^treeDepth);
    meanRotSimilarity = mean(predNormRotSimilarity);
    rotationSimilarity = [rotationSimilarity; meanRotSimilarity];
end

%% Capture-Range Plot
figure(1);
%plot3(translations(:,1),translations(:,2),translationSimilarity);
% Plot a 3D Surface Plot for Translation Similarity
X = reshape(translations(:,1),[sqrt(totalTranlations),sqrt(totalTranlations)]);
Y = reshape(translations(:,2),[sqrt(totalTranlations),sqrt(totalTranlations)]);
Z = reshape(translationSimilarity,[sqrt(totalTranlations),sqrt(totalTranlations)]);
plot3(translations(:,1),translations(:,2),translationSimilarity,'o-');
%surf(X,Y,Z);

xlabel('Translations along X');
ylabel('Translations along Y');
zlabel('0 \leq Similarity \leq 1');
title('Capture-Range Plot for Translational Similarity');

figure(2);
plot(rotations,rotationSimilarity);
xlabel('Rotations');
ylabel('0 \leq Similarity \leq 1');
title('Capture-Range Plot for Rotational-Similarity');

predictedSimilarity = XTest * Weights';

% Normalise over the number of trees such that the final similarity value is between 0 and 1.
predNormSimilarity = predictedSimilarity./(2^treeDepth);


%% Evaluation - Performance Measures!

%% =========== Classification - Confusion Matrix =============
% Define the vectors for the ground truth and the predicted class for each sample.
groundTruth = TestGroundTruthSimilarity; %[1,0,0,1,0,0,1,1,0,1,0,0,1,1,0,0,1,1,0,1,0,1]';
Predictions = predNormSimilarity; %predictedSimilarity; %[0.6,0.2,0.3,0.5,0.9,0.8,0.6,0.3,0.1,0.2,0.1,0.5,0.8,0.1,0.3,0.7,0.8,0.2,0.4,0.4,0.5,0.4]';

minPredNormSimilarity = min(predNormSimilarity);
maxPredNormSimilarity = max(predNormSimilarity);
rangePredNormSimilarity = maxPredNormSimilarity - minPredNormSimilarity;
stepSize = rangePredNormSimilarity/10;

thresholdVec = [];
t = minPredNormSimilarity;
while(t<=maxPredNormSimilarity)
    thresholdVec = [thresholdVec,t];
    t = t + stepSize;
end

%thresholdVec = [0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1];
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
figure(3);
plot(1 - specificityVec, sensitivityVec,'-*');
xlabel('0 \leq False Positive Rate(FPR) \leq 1');
ylabel('0 \leq Sensitivity \leq 1');
title('ROC Curve');

% Part b. Precision-Recall curve
% Precision = Positive predictive value (PPV)
% Recall = Sensitivity !!
figure(4);
plot(PPVVec, sensitivityVec,'-o');
xlabel('0 \leq Precision = Positive predictive value (PPV) \leq 1');
ylabel('0 \leq Recall = Sensitivity \leq 1');
title('Precision-Recall(PR) Curve');

