load('TrainingSamplesDCT_8_new.mat','TrainsampleDCT_BG');
load('TrainingSamplesDCT_8_new.mat','TrainsampleDCT_FG');


[rf,cf]= size(TrainsampleDCT_FG);
[rb,cb]= size(TrainsampleDCT_BG);

%Part A

cheetah_priori= rf/(rf+rb);
grass_priori= rb/(rb+rf);

fprintf("Cheetah Priori: %d\n",cheetah_priori);
fprintf("Grass Priori: %d\n",grass_priori);


%Count Histogram:
figure;
bar([rf,rb]);
xlabel('Feature counts for Cheetah and Grass');
ylabel("No. of Features");

%Priori Hisogram:
figure;
bar([cheetah_priori,grass_priori]);
xlabel("Prior Probability for Cheetah and Grass");
ylabel("Probability");



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Part B


BG_SampleMean = sum(TrainsampleDCT_BG)/(rb);
BG_Samplestd= std(TrainsampleDCT_BG);
BG_SampleCov= cov(TrainsampleDCT_BG);

FG_Samplestd= std(TrainsampleDCT_FG);
FG_SampleCov= cov(TrainsampleDCT_FG);
FG_SampleMean= sum(TrainsampleDCT_FG)/(rf);



for i=1:64
    x1(i,:) = (BG_SampleMean(i) - 7*BG_Samplestd(i)):(BG_Samplestd(i)/60):(BG_SampleMean(i)+7*BG_Samplestd(i));
    y1(i, :) = normpdf(x1(i,:),BG_SampleMean(i), BG_Samplestd(i));
    
    x2(i,:) = (FG_SampleMean(i) - 7*FG_Samplestd(i)):(FG_Samplestd(i)/60):(FG_SampleMean(i)+7*FG_Samplestd(i));
    y2(i, :) = normpdf(x2(i,:),FG_SampleMean(i), FG_Samplestd(i));
end


for k = 0:3
    figure;
    for i = 1:16
        subplot(4,4,i);
        plot(x1(i+16*k, :),y1(i+16*k, :),'-b',x2(i+16*k, :),y2(i+16*k, :),'-r');
        title(['dimension ',num2str(i+16*k)]);
    end
end

best= [1,7,14,17,24,26,31,40];
worst= [3,4,5,59,60,62,63,64];

figure;
for i = 1:8
    count = best(i);
    
    subplot(2,4,i);
    plot(x1(count,:),y1(count, :),'-b',x2(count,:),y2(count, :),'-r');
    title(['dimension ',num2str(count)]);

end

figure;
for i = 1:8
    count = worst(i);
    
    subplot(2,4,i);
    plot(x1(count,:),y1(count, :),'-b',x2(count,:),y2(count, :),'-r');
    title(['dimension ',num2str(count)]);

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Part C


pad_size=[1,2];
img = imread("cheetah.bmp");
[height1,width1]=size(img);
B= padarray(img,pad_size,'replicate','post');

B_norm = double(B)./255.0;

[height,width]=size(B);

fprintf("h %d\n",height);
fprintf("w %d\n",width);


%ZigZag Function

function zigzag_dct= ZigZag(x)
    A= load('zigzag.txt');
    zigzag_dct=[1:64];
    for i=1:8
        for j=1:8
            zigzag_dct(A(i,j)+1)=x(i,j);
        end
    end
end

%Mask for 64-Dimensions

BG_SampleMean = sum(TrainsampleDCT_BG)/(rb);
BG_Samplestd= std(TrainsampleDCT_BG);
BG_SampleCov= cov(TrainsampleDCT_BG);
BG_SampleCov_inv= inv(BG_SampleCov);

FG_SampleMean= sum(TrainsampleDCT_FG)/(rf);
FG_Samplestd= std(TrainsampleDCT_FG);
FG_SampleCov= cov(TrainsampleDCT_FG);
FG_SampleCov_inv= inv(FG_SampleCov);



cheetah_denom = sqrt(((2*3.14)^64)*det(FG_SampleCov_inv));
grass_denom = sqrt(((2*3.14)^64)*det(BG_SampleCov_inv));

mask64= [];

for i= 1:height-7
    temp=[];
    for j= 1:width-7
        x= dct2(B_norm(i:i+7,j:j+7));
        zigzag_dct= ZigZag(x);
        Gaussian_cheetah_probability = exp(-0.5*(zigzag_dct-FG_SampleMean)*FG_SampleCov_inv*(zigzag_dct-FG_SampleMean).')/cheetah_denom;
        Gaussian_grass_probability = exp(-0.5*(zigzag_dct-BG_SampleMean)*BG_SampleCov_inv*(zigzag_dct-BG_SampleMean).')/grass_denom;
        Cheetah_prob = Gaussian_cheetah_probability * cheetah_priori;
        Grass_prob = Gaussian_grass_probability * grass_priori;
        if(Cheetah_prob>Grass_prob)
            temp=[temp,1];
        else
            temp=[temp,0];
        end
    end
    mask64=[mask64;temp];
end

figure;
imshow(mask64/255);
colormap("gray");
title("Mask for 64D");

%Error Rate

orignal_mask = imread("cheetah_mask.bmp");


[r1,c1] = size(img);

total_val=0;

for i= 1:r1
    for j= 1:c1
        if(orignal_mask(i,j)~=mask64(i,j))
            total_val=total_val+1;
        end
    end
end

fprintf("Error Rate for 64D: %d\n",total_val/r1*c1);


