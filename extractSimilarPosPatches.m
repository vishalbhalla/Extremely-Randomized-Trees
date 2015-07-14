function similarity = extractSimilarPosPatches(originalImage, transformedImage, patchSize, noOfsample)

% img1 = imread(imgPath1);
% img2 = imread(imgPath2);

similarity = [];

img1 = originalImage;
img2 = transformedImage;

index = floor(patchSize/2);
img1 = padarray(img1,[index,index]) ;
img2 = padarray(img2,[index,index]) ;

for k = 1:noOfsample
    
    i_new = randi(256);
    j_new = randi(256);
  
    if(i_new + index > 256)
        i_new = mod(i_new - index,256);
    end
    if(i_new - index < 1 )
        i_new = mod(i_new + index,256);
    end
    if(j_new + index > 256)
        j_new = mod(j_new - index,256);
    end
    if(j_new - index < 1)
        j_new = mod(j_new + index,256);
    end
    
    matrix1 = img1(i_new-index+1:i_new+index+1,j_new-index+1:j_new+index+1);
    matrix2 = img2(i_new-index+1:i_new+index+1,j_new-index+1:j_new+index+1);

    conc_matrix_similarity = [matrix1 ;matrix2];
    num = numel(conc_matrix_similarity);
    similarity_matrix = reshape(conc_matrix_similarity',[1,num]);
    similarity = [similarity;similarity_matrix];
end

end
