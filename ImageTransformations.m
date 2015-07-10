function [I, transformedImage] = ImageTransformations(imagePath, transformation, boolTranslationRotation)
%% Testing - Transformations on an image.
% Translation and Rotation

I=imread(imagePath);
%imshow(I);
  
% Translating an Image
if(boolTranslationRotation)
    transformedImage = imtranslate(I,transformation,'FillValues',0);
else % Rotatiting an Image
    transformedImage = imrotate(I,transformation);
end
%imshow(transformedImage);

end
