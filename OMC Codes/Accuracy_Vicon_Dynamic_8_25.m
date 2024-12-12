%% ACCURACY VICON DYNAMIC%%

%This code takes the alignment matrices and calculates segment ROM during
%the various dynamic tasks. 

%Last updated by Anna Bailes 9/5/23

%% CREATE SUBJECT FOLDER

close all;clear all; clc;

subject=input('Enter Subject ID: LW_','s');
folder= strcat('P:\Lifeware Accuracy Study\Vicon Codes\Fall 23 Analysis\',subject);
mkdir(folder)

%% LOAD DYNAMIC TEXT FILE

cd(strcat('P:\Lifeware Accuracy Study\Data\LW_',subject,'\Session1\'));
data_folder=strcat('P:\Lifeware Accuracy Study\Data\LW_',subject,'\Session1\');
trial_txt = uigetfile('.txt', data_folder,'Select Dynamic Trial');

cd('P:\Lifeware Accuracy Study\Vicon Codes\Fall 23 Analysis');
addpath(strcat('P:\Lifeware Accuracy Study\Data\LW_',subject,'\Session1\'));
txt2mat(trial_txt)  %Calls function made by Arash Mahboobin

matfile=strcat(trial_txt(1:end-4),'.mat');
load(matfile)
status=movefile(matfile,folder);

%% LOAD TRIAL DESCRIPTION SPREADSHEET
trial_dex=readtable(strcat('P:\Lifeware Accuracy Study\Data\','LW_',subject,'\','LW_',subject,'_','TrialDescriptionSpreadsheet.xlsx'));
size=size(trial_dex,1);

for i=1:size
    tf=strcmp(trial_dex{i,1},trial_txt(1:end-4));
    if tf==1
        trial_name=trial_dex{i,2};
        trial_name=char(trial_name);
    end
end

%% LOAD SAVED ALIGNMENT MATRICES

path=strcat('P:\Lifeware Accuracy Study\Vicon Codes\Fall 23 Analysis\',subject,'\');

fname_T1 = uigetfile(strcat(path,'.mat'), 'Select T1 ALIGNMENT Matrix');
fname_L1 = uigetfile(strcat(path,'.mat'), 'Select L1 ALIGNMENT Matrix');
fname_L5 = uigetfile(strcat(path,'.mat'), 'Select L5 ALIGNMENT Matrix');
fname_Hip = uigetfile(strcat(path,'.mat'), 'Select Hip ALIGNMENT Matrix');

R_T1a_T1m = load(strcat(path,'/',fname_T1)); 
R_L1a_L1m = load(strcat(path,'/',fname_L1)); 
R_L5a_L5m = load(strcat(path,'/',fname_L5));
R_Hipa_Hipm = load(strcat(path,'/',fname_Hip));

R_T1a_T1m = R_T1a_T1m.align_T1; %Alignment matrices (measured to anatomical)
R_L1a_L1m = R_L1a_L1m.align_L1; 
R_L5a_L5m = R_L5a_L5m.align_L5; 
R_Hipa_Hipm = R_Hipa_Hipm.align_Hip; 

R_T1m_T1a = R_T1a_T1m'; %Alignment matrices (anatomical to measured)
R_L1m_L1a = R_L1a_L1m'; 
R_L5m_L5a = R_L5a_L5m'; 
R_Hipm_Hipa = R_Hipa_Hipm'; 

%% CALCULATE DYNAMIC ROTATION MATRICS (MEASURED TO GLOBAL) USING DOUBLE CROSS PRODUCT

vector1_T1 = AL-AR; %Same definition as Alignment code
vector2_T1 = AT-AR;

vector1_L1 = BL-BR; 
vector2_L1 = BT-BR;

vector1_L5 = CL-CR; 
vector2_L5 = CT-CR;

vector1_Hip = DB-DF; 
vector2_Hip = DT-DF;

data_len = length(time);

for i=1:data_len
    vector3_T1(i,:) = cross(vector1_T1(i,:),vector2_T1(i,:));
    vector4_T1(i,:) = cross(vector3_T1(i,:),vector1_T1(i,:));
    vector3_L1(i,:) = cross(vector1_L1(i,:),vector2_L1(i,:));
    vector4_L1(i,:) = cross(vector3_L1(i,:),vector1_L1(i,:));
    vector3_L5(i,:) = cross(vector1_L5(i,:),vector2_L5(i,:));
    vector4_L5(i,:) = cross(vector3_L5(i,:),vector1_L5(i,:)); 
    vector3_Hip(i,:) = cross(vector1_Hip(i,:),vector2_Hip(i,:));
    vector4_Hip(i,:) = cross(vector3_Hip(i,:),vector1_Hip(i,:)); 
end


for i=1:data_len
    x_T1(i,:)=vector1_T1(i,:)/norm(vector1_T1(i,:)); %Same definition as Alignment Code
    y_T1(i,:)=vector3_T1(i,:)/norm(vector3_T1(i,:));
    z_T1(i,:)=-vector4_T1(i,:)/norm(vector4_T1(i,:));
   
    x_L1(i,:)=vector1_L1(i,:)/norm(vector1_L1(i,:));
    y_L1(i,:)=vector3_L1(i,:)/norm(vector3_L1(i,:));
    z_L1(i,:)=-vector4_L1(i,:)/norm(vector4_L1(i,:));

    x_L5(i,:)=-vector1_L5(i,:)/norm(vector1_L5(i,:));
    y_L5(i,:)=vector3_L5(i,:)/norm(vector3_L5(i,:));
    z_L5(i,:)=vector4_L5(i,:)/norm(vector4_L5(i,:));
   
    x_Hip(i,:)=-vector3_Hip(i,:)/norm(vector3_Hip(i,:));
    y_Hip(i,:)=-vector1_Hip(i,:)/norm(vector1_Hip(i,:));
    z_Hip(i,:)=vector4_Hip(i,:)/norm(vector4_Hip(i,:));
end
    
%Measured LCS to global. There will be one rotation matrix for
%each frame collected in Vicon throughout dynamic movement.

for i=1:data_len
    R_g_T1m(:, :, i) = [x_T1(i,:)', y_T1(i,:)', z_T1(i,:)'];

    R_g_L1m(:, :, i) = [x_L1(i,:)', y_L1(i,:)', z_L1(i,:)'];
    R_L1m_g(:,:,i)=R_g_L1m(:,:,i)';

    R_g_L5m(:, :, i) = [x_L5(i,:)', y_L5(i,:)', z_L5(i,:)'];
    R_L5m_g(:,:,i)=R_g_L5m(:,:,i)';

    R_g_Hipm(:, :, i) = [x_Hip(i,:)', y_Hip(i,:)', z_Hip(i,:)'];
end

%% CREATE ROTATION MATRICES

%Calculates sensor1 anatomical wrt sensor2 anatomical

for i=1:data_len
    %Prioritize axial rotation as primary angle for decomposition
    if contains(trial_name,'Rot')
         R_L5a_T1a(:,:,i)=R_L5a_L5m*R_L5m_g(:,:,i)*R_g_T1m(:,:,i)*R_T1m_T1a;
         R_L5a_L1a(:,:,i)=R_L5a_L5m*R_L5m_g(:,:,i)*R_g_L1m(:,:,i)*R_L1m_L1a;
         R_L5a_Hipa(:,:,i)=R_L5a_L5m*R_L5m_g(:,:,i)*R_g_Hipm(:,:,i)*R_Hipm_Hipa;
         R_L1a_T1a(:,:,i)=R_L1a_L1m*R_L1m_g(:,:,i)*R_g_T1m(:,:,i)*R_T1m_T1a; 
       
    %Prioritize lateral bend as primary angle for decomposition
    elseif contains(trial_name,'SB') 
         R_L5a_T1a(:,:,i)=R_L5a_L5m*R_L5m_g(:,:,i)*R_g_T1m(:,:,i)*R_T1m_T1a; 
         R_L5a_L1a(:,:,i)=R_L5a_L5m*R_L5m_g(:,:,i)*R_g_L1m(:,:,i)*R_L1m_L1a; 
         R_L5a_Hipa(:,:,i)=R_L5a_L5m*R_L5m_g(:,:,i)*R_g_Hipm(:,:,i)*R_Hipm_Hipa;  
         R_L1a_T1a(:,:,i)=R_L1a_L1m*R_L1m_g(:,:,i)*R_g_T1m(:,:,i)*R_T1m_T1a; 
         
    %Prioritize flex/ext as primary angle for decomposition
    elseif contains(trial_name,'flex') || contains(trial_name,'ext') || contains(trial_name,'STS')|| contains(trial_name,'gait')
         R_L5a_T1a(:,:,i)=R_L5a_L5m*R_L5m_g(:,:,i)*R_g_T1m(:,:,i)*R_T1m_T1a; 
         R_L5a_L1a(:,:,i)=R_L5a_L5m*R_L5m_g(:,:,i)*R_g_L1m(:,:,i)*R_L1m_L1a; 
         R_L5a_Hipa(:,:,i)=R_L5a_L5m*R_L5m_g(:,:,i)*R_g_Hipm(:,:,i)*R_Hipm_Hipa;
         R_L1a_T1a(:,:,i)=R_L1a_L1m*R_L1m_g(:,:,i)*R_g_T1m(:,:,i)*R_T1m_T1a; 
    end
end

%% CREATE ROTATION MATRIX AT END OF TRIAL FOR 'ZEROING'

for j=1:3;
    for i=1:3
        static_L5T1(i,j)=mean(R_L5a_T1a(i,j,end-4:end)); %average across last 5 points of trial
        static_L5L1(i,j)=mean(R_L5a_L1a(i,j,end-4:end));
        static_L5Hip(i,j)=mean(R_L5a_Hipa(i,j,end-4:end));
        static_L1T1(i,j)=mean(R_L1a_T1a(i,j,end-4:end));
    end
end
    
statinv_L5T1=static_L5T1'; %take inverse of rotation matrix
statinv_L5L1=static_L5L1';
statinv_L5Hip=static_L5Hip';
statinv_L1T1=static_L1T1';

%% RE-CALCULATE EULER ANGLES AFTER 'ZEROING'

%Calculates sensor1 anatomical wrt sensor2 anatomical

for i=1:data_len
    %Prioritize axial rotation as primary angle for decomposition
    if contains(trial_name,'Rot')
         R_L5a_T1a(:,:,i)=R_L5a_L5m*R_L5m_g(:,:,i)*R_g_T1m(:,:,i)*R_T1m_T1a*statinv_L5T1; 
         T1L5_angles(i,:) = rmx2eul_zxy(R_L5a_T1a(:, :,i)); % calls function  

         R_L5a_L1a(:,:,i)=R_L5a_L5m*R_L5m_g(:,:,i)*R_g_L1m(:,:,i)*R_L1m_L1a*statinv_L5L1; 
         L1L5_angles(i,:) = rmx2eul_zxy(R_L5a_L1a(:, :,i)); % calls function  

         R_L5a_Hipa(:,:,i)=R_L5a_L5m*R_L5m_g(:,:,i)*R_g_Hipm(:,:,i)*R_Hipm_Hipa*statinv_L5Hip; 
         HipL5_angles(i,:) = rmx2eul_zxy(R_L5a_Hipa(:, :,i)); % calls function

         R_L1a_T1a(:,:,i)=R_L1a_L1m*R_L1m_g(:,:,i)*R_g_T1m(:,:,i)*R_T1m_T1a*statinv_L1T1; 
         T1L1_angles(i,:) = rmx2eul_zxy(R_L1a_T1a(:, :,i)); % calls function  
  
    %Prioritize lateral bend as primary angle for decomposition
    elseif contains(trial_name,'SB') 
    
         R_L5a_T1a(:,:,i)=R_L5a_L5m*R_L5m_g(:,:,i)*R_g_T1m(:,:,i)*R_T1m_T1a*statinv_L5T1; 
         T1L5_angles(i,:) = rmx2eul_yxz(R_L5a_T1a(:, :,i)); % calls function  

         R_L5a_L1a(:,:,i)=R_L5a_L5m*R_L5m_g(:,:,i)*R_g_L1m(:,:,i)*R_L1m_L1a*statinv_L5L1; 
         L1L5_angles(i,:) = rmx2eul_yxz(R_L5a_L1a(:, :,i)); % calls function  

         R_L5a_Hipa(:,:,i)=R_L5a_L5m*R_L5m_g(:,:,i)*R_g_Hipm(:,:,i)*R_Hipm_Hipa*statinv_L5Hip; 
         HipL5_angles(i,:) = rmx2eul_yxz(R_L5a_Hipa(:, :,i)); % calls function  

         R_L1a_T1a(:,:,i)=R_L1a_L1m*R_L1m_g(:,:,i)*R_g_T1m(:,:,i)*R_T1m_T1a*statinv_L1T1; 
         T1L1_angles(i,:) = rmx2eul_yxz(R_L1a_T1a(:, :,i)); % calls function  
   
    %Prioritize flex/ext as primary angle for decomposition
    elseif contains(trial_name,'flex') || contains(trial_name,'ext') || contains(trial_name,'STS')|| contains(trial_name,'gait')
         R_L5a_T1a(:,:,i)=R_L5a_L5m*R_L5m_g(:,:,i)*R_g_T1m(:,:,i)*R_T1m_T1a*statinv_L5T1; 
         T1L5_angles(i,:) = rmx2eul_xyz(R_L5a_T1a(:, :,i)); % calls function  
    
         R_L5a_L1a(:,:,i)=R_L5a_L5m*R_L5m_g(:,:,i)*R_g_L1m(:,:,i)*R_L1m_L1a*statinv_L5L1; 
         L1L5_angles(i,:) = rmx2eul_xyz(R_L5a_L1a(:, :,i)); % calls function  
    
         R_L5a_Hipa(:,:,i)=R_L5a_L5m*R_L5m_g(:,:,i)*R_g_Hipm(:,:,i)*R_Hipm_Hipa*statinv_L5Hip; 
         HipL5_angles(i,:) = rmx2eul_xyz(R_L5a_Hipa(:, :,i)); % calls function

         R_L1a_T1a(:,:,i)=R_L1a_L1m*R_L1m_g(:,:,i)*R_g_T1m(:,:,i)*R_T1m_T1a*statinv_L1T1; 
         T1L1_angles(i,:) = rmx2eul_xyz(R_L1a_T1a(:, :,i)); % calls function 

    end
end

%% UNWRAPPING AND CONVERT TO DEGREES 

%Unwrapping
for j = 1:3
    if find(abs(diff(T1L5_angles(:, j))) > pi)
        T1L5_angles(:, j) = unwrap(T1L5_angles(:, j));
        disp('UNWRAPPING');
    end
    if find(abs(diff(L1L5_angles(:,j))) > pi)
        L1L5_angles(:,j) = unwrap(L1L5_angles(:,j));
        disp('UNWRAPPING');
    end
    if find(abs(diff(HipL5_angles(:,j))) > pi)
        HipL5_angles(:,j) = unwrap(HipL5_angles(:,j));
        disp('UNWRAPPING');
    end
    if find(abs(diff(T1L1_angles(:,j))) > pi)
        T1L1_angles(:,j) = unwrap(T1L1_angles(:,j));
        disp('UNWRAPPING');
    end
end

for i=1:data_len
    Vicon_ROM_T1L5(i, :) = rad2deg(T1L5_angles(i, :)); 
    Vicon_ROM_L1L5(i, :) = rad2deg(L1L5_angles(i, :)); 
    Vicon_ROM_HipL5(i, :) = rad2deg(HipL5_angles(i, :));
    Vicon_ROM_T1L1(i, :) = rad2deg(T1L1_angles(i, :)); 
end
   
%% PLOT ROM

close all;
index=1; %look at graph first and then fill in with index of start of movement

Vicon_ROM_T1L5=Vicon_ROM_T1L5(index:end,:);
Vicon_ROM_L1L5=Vicon_ROM_L1L5(index:end,:);
Vicon_ROM_HipL5=Vicon_ROM_HipL5(index:end,:);
Vicon_ROM_T1L1=Vicon_ROM_T1L1(index:end,:);

folder= strcat('P:\Lifeware Accuracy Study\Vicon Codes\Fall 23 Analysis\',subject);
mkdir(folder)

%Axial Rotation Plots-zxy
if contains(trial_name,'Rot')
    figure(2)
    subplot(411);hold on
    plot(Vicon_ROM_T1L5);
    title('T1L5angles')
    ylabel('Degrees'); title('T1L5 Range of Motion');
    legend('AxRot','FlexExt','LatBend')

    subplot(412);hold on
    plot(Vicon_ROM_L1L5);
    title('L1L5angles')
    legend('AxRot','FlexExt','LatBend')
    ylabel('Degrees'); title('Lumbar Range of Motion');

    subplot(413);hold on
    plot(Vicon_ROM_HipL5);
    title('HipL5angles')
    legend('AxRot','FlexExt','LatBend')
    ylabel('Degrees'); title('Hip Range of Motion');
    hold off;

    subplot(414);hold on
    plot(Vicon_ROM_T1L1);
    title('T1L1angles')
    legend('AxRot','FlexExt','LatBend')
    ylabel('Degrees'); title('Thoracic Range of Motion');
    hold off;
    sgtitle(convertCharsToStrings(trial_name))
    
    saveas(gcf,strcat(folder,'\',trial_name,'.jpeg'));

%Lateral Bend Plots-yxz
    elseif contains(trial_name,'SB') 
    figure()
    subplot(411);hold on
    plot(Vicon_ROM_T1L5);
    title('T1L5angles');
    legend('LatBend','FlexExt','AxRot');
    ylabel('Degrees'); title('T1L5 Range of Motion');

    subplot(412);hold on
    plot(Vicon_ROM_L1L5);
    title('L1L5angles');
    legend('LatBend','FlexExt','AxRot');
    ylabel('Degrees'); title('Lumbar Range of Motion');

    subplot(413);hold on
    plot(Vicon_ROM_HipL5);
    title('HipL5angles');
    legend('LatBend','FlexExt','AxRot');
    ylabel('Degrees'); title('Hip Range of Motion');
    hold off;

    subplot(414);hold on
    plot(Vicon_ROM_T1L1);
    title('T1L1angles');
    legend('LatBend','FlexExt','AxRot');
    ylabel('Degrees'); title('Thoracic Range of Motion');
    hold off;
    sgtitle(convertCharsToStrings(trial_name))

    saveas(gcf,strcat(folder,'\',trial_name,'.jpeg'));

%Flexion Extension Plots-xyz
    elseif contains(trial_name,'flex') || contains(trial_name,'ext') || contains(trial_name,'STS')|| contains(trial_name,'gait')
    figure()
    subplot(411);hold on
    plot(Vicon_ROM_T1L5);
    legend('FlexExt','LatBend','AxRot')
    ylabel('Degrees'); title('T1L5 Range of Motion');

    subplot(412);hold on
    plot(Vicon_ROM_L1L5);
    legend('FlexExt','LatBend','AxRot')
    ylabel('Degrees'); title('Lumbar Range of Motion');

    subplot(413);hold on
    plot(Vicon_ROM_HipL5);
    legend('FlexExt','LatBend','AxRot')
    ylabel('Degrees'); title('Hip Range of Motion');
    hold off;

    subplot(414);hold on
    plot(Vicon_ROM_T1L1);
    legend('FlexExt','LatBend','AxRot')
    ylabel('Degrees'); title('Thoracic Range of Motion');
    hold off;
    sgtitle(convertCharsToStrings(trial_name))

    saveas(gcf,strcat(folder,'\',trial_name,'.jpeg'));
end

%% SAVE ROM DATA

filename=strcat(folder,'\',subject,'_Vicon_',trial_name,'_ROM.mat');
save(filename,'Vicon_ROM_T1L5','Vicon_ROM_L1L5','Vicon_ROM_HipL5','Vicon_ROM_T1L1');




