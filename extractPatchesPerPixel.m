%function [similarity, disSimilarity] = extractPatchesPerPixel(imgPath1, imgPath2, pixel_i, pixel_j, patchSize, noOfsample)
function [similarity, disSimilarity] = extractPatchesPerPixel(originalImage, transformedImage, pixel_i, pixel_j, patchSize, noOfsample)

% img1 = imread(imgPath1);
% img2 = imread(imgPath2);

img1 = originalImage;
img2 = transformedImage;

i = pixel_i;
j = pixel_j;

noOfPosSample = noOfsample;
noOfNegSample = noOfsample;
patchSize ;
index = floor(patchSize/2);
img1 = padarray(img1,[index,index]) ;
img2 = padarray(img2,[index,index]) ;

%%for positive samples, take same amount of  
%for m = 1:noOfPosSample
%    i = i + randi(255)
%    j = j + randi(255)
    
while(i - index <= 1 || i > 255 )  
   i = i + randi(255);
   i = mod(i,256);

end

while (j - index <= 1 || j > 255)
    j = j + randi(255);
    j = mod(j,256);

end

matrix1 = img1(i-index+1:i+index+1,j-index+1:j+index+1);
matrix2 = img2(i-index+1:i+index+1,j-index+1:j+index+1);

conc_matrix_similarity = [matrix1 ;matrix2];
num = numel(conc_matrix_similarity);
similarity_matrix = reshape(conc_matrix_similarity',[1,num]);
similarity{1} = similarity_matrix;
%similarity{m} = similarity_matrix

for k = 1:noOfNegSample-1
    
    i_new = i+randi(256);
    j_new = j+randi(256);
  
    while(i_new > 256 || i_new == i || i_new - index < 1 )
        i_new = i_new+randi(256);
        i_new = mod(i_new,256);
 
    end
    while(j_new > 256 || j_new == j || j_new - index < 1 )
        j_new = j_new+randi(256);
        j_new = mod(j_new,256);

    end
    
    matrix3 =img2(i_new-index+1:i_new+index+1,j_new-index+1:j_new+index+1) ;
    conc_matrix_disSimilarity = [matrix1 ;matrix3];
    num = numel(conc_matrix_disSimilarity);
    disSimilarity_matrix = reshape(conc_matrix_disSimilarity',[1,num]);
    disSimilarity{k} = disSimilarity_matrix;
    %disSimilarity{k} = conc_matrix_disSimilarity
  
end

end

