%PartA and B
load('TrainingSamplesDCT_8.mat','TrainsampleDCT_BG');
load('TrainingSamplesDCT_8.mat','TrainsampleDCT_FG');

[rf,cf]= size(TrainsampleDCT_FG);
[rb,cb]= size(TrainsampleDCT_BG);

cheetah_priori = rf/(rf+rb);
grass_priori = rb/(rf+rb);

fprintf('Cheetah Priori: %f',cheetah_priori);
fprintf('Grass Priori: %f', grass_priori);

fprintf('\n');

%Cheetah Probability:
cheetah_histogram=[];
prob_of_feat_given_cheetah= zeros(64,1);

for i=1:rf
    x= TrainsampleDCT_FG(i,:);
    [x,y]= sort(x,"descend");
    cheetah_histogram=[cheetah_histogram,y(2)];
    prob_of_feat_given_cheetah(ceil(y(2)))= prob_of_feat_given_cheetah(ceil(y(2)))+1;
end

hist(cheetah_histogram,cf,'Normalization','probability');
xlabel('Cheetah Features');
ylabel('Probability');
cheetah_probability= prob_of_feat_given_cheetah/rf;

%Grass Probability:
grass_histogram=[];
prob_of_feat_given_grass= zeros(64,1);

for i=1:rb
    x= TrainsampleDCT_BG(i,:);
    [x,y]= sort(x,"descend");
    grass_histogram=[grass_histogram,y(2)];
    prob_of_feat_given_grass(ceil(y(2)))= prob_of_feat_given_grass(ceil(y(2)))+1;
end

hist(grass_histogram,cf,'Normalization','probability');
xlabel('Grass Features');
ylabel('Probability');
grass_probability= prob_of_feat_given_grass/rb;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PartC and D

%Creating Mask
pad_size=[1,2];
img = imread("cheetah.bmp");
[height1,width1]=size(img);
B= padarray(img,pad_size,'circular','post');

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

%BDR Calculations

mask= [];

for i= 1:height-7
    temp=[];
    for j= 1:width-7
        x= dct2(B(i:i+7,j:j+7));
        zigzag_dct= ZigZag(x);
        [x,y]= sort(zigzag_dct,"descend");
        Cheetah_prob= cheetah_probability(ceil(y(2)))*cheetah_priori;
        Grass_prob= grass_probability(ceil(y(2)))*grass_priori;
        if(Cheetah_prob>Grass_prob)
            temp=[temp,1];
        else
            temp=[temp,0];
        end
    end
    mask=[mask;temp];
end

output_img= imshow(mask);
colormap("gray");

%Error Rate

masked_image= imread('cheetah_mask.bmp')

error_rate=0;
for i=1:height1
    for j=1:width1
        if(mask(i,j)~=masked_image(i,j))
            error_rate=error_rate+1;
        end
    end
end
fprintf("Error Rate: %d\n",error_rate/(height1*widht1));