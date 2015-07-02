
% Extremely Randomised Forests - Ensemble of Trees.
totalTrees = 10;
structForest = {};

for nt=1:totalTrees;
    structTree = constructTree();
    structForest = [structForest; structTree];
end

noPatches = 20;

% Code Vectors
X = [];

patchSize= 15;
totalPtsInPatch = patchSize*patchSize;
pixel_position_x = randi(256);
pixel_position_y = randi(256);
noOfSample = noPatches+1;


% base_T1 = '/Users/chingyukao/Documents/MATLAB/Multi-Modal-Similarity-till-08062015/Multi-Modal-Similarity/Dataset/T1_';
% base_T2 = '/Users/chingyukao/Documents/MATLAB/Multi-Modal-Similarity-till-08062015/Multi-Modal-Similarity/Dataset/T2_';

base_T1 = 'E:\TUM\Courses\Summer Semester 2015\Machine Learning in Medical Imaging\Project\Extremely Randomized Trees\Dataset\T1_';
base_T2 = 'E:\TUM\Courses\Summer Semester 2015\Machine Learning in Medical Imaging\Project\Extremely Randomized Trees\Dataset\T2_';

patchPairMatrix = [];
for i = 1:12
    %path = strcat(base,num2str(i),'.TIFF');
    if( i ~= 8)
    if(i<10)
        j = strcat('0',num2str(i));
    end
        
    imagePath1 = strcat(base_T1,num2str(j),'.TIFF');
    imagePath2 = strcat(base_T2,num2str(j),'.TIFF');
    

    noOfPosPatches = 10;

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
     X1 = [] ;
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
% Now calculate the weights for each leaf in every tree of the forest.
Weights = [];
for nt=1:totalTrees;
    structTree = structForest{nt};
    w = CalculateWeights(structTree);
    Weights = [Weights, w];
end

%Use the weights to define the similarity measure of the test data set.



