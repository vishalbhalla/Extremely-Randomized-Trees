function [patchSize, treeDepth, noTreeNodes, noOfPosPatches, noPatches, noOfSample, totalTreesInForest, trainingDataPath, testDataPath] = TuningParametersConfig()
%TUNING PARAMETERS

patchSize = 15;
treeDepth = 3;
noTreeNodes = 2^(treeDepth + 1) - 1;
totalTreesInForest = 10;

noOfPosPatches = 10;
noPatches = 20;
noOfSample = noPatches + 1;

trainingDataPath = strcat(pwd,'\DataSet\Training\');
testDataPath = strcat(pwd,'\DataSet\Test');

end