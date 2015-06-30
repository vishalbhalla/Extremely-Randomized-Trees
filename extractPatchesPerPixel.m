function [ similarity, disSimilarity ] = extractPatchesPerPixel(imgPath1, imgPath2, pixel_i, pixel_j, patchSize,noOfsample )
%img1 = dlmread('image1.txt')
%img2 = dlmread('image2.txt')

%img1 = imread('/Users/chingyukao/Documents/MATLAB/Multi-Modal-Similarity-till-08062015/Multi-Modal-Similarity/Dataset/T1_11.TIFF');
%img2 = imread('/Users/chingyukao/Documents/MATLAB/Multi-Modal-Similarity-till-08062015/Multi-Modal-Similarity/Dataset/T2_11.TIFF');

img1 = imread(imgPath1);
img2 = imread(imgPath2);
i = pixel_i;
j = pixel_j;

noOfPosSample = noOfsample/2;
noOfNegSample = noOfsample/2;
patchSize ;
index = floor(patchSize/2);
img1 = padarray(img1,[index,index]);
img2 = padarray(img2,[index,index]);

for m = 1:noOfPosSample
    i = i + randi(255);
    j = j + randi(255);
while(i - index <= 1 | i >255 ) 
   i = i + randi(255);
   i = mod(i,256);
   
end

while (j - index <= 1| j > 255)
    j = j + randi(255);
    j = mod(j,256);
    
end



matrix1 = img1(i-index+1:i+index+1,j-index+1:j+index+1);
matrix2 = img2(i-index+1:i+index+1,j-index+1:j+index+1);

conc_matrix_similarity = [matrix1 ;matrix2];
num = numel(conc_matrix_similarity);
similarity_matrix = reshape(conc_matrix_similarity',[1,num]);
%similarity{1} = conc_matrix_similarity
similarity{m} = similarity_matrix;

for k = 1:noOfNegSample
    X = randi(255);
    i_new = i+X;
    j_new = j+X;
    while(i_new > 255 | i_new == i | i_new - index <= 1 )
        i_new = i_new+X;
        i_new = mod(i_new,256);
    end
    while(j_new > 255| j_new == j | j_new - index <= 1 )
        j_new = j_new+X;
        j_new = mod(j_new,256);
    end
    
    matrix3 =img2(i_new-index+1:i_new+index+1,j_new-index+1:j_new+index+1);
    conc_matrix_disSimilarity = [matrix1 ;matrix3];
    num = numel(conc_matrix_similarity);
    disSimilarity_matrix = reshape(conc_matrix_disSimilarity',[1,num]);
    disSimilarity{k} = disSimilarity_matrix
    %disSimilarity{k} = conc_matrix_disSimilarity
end


end

end

