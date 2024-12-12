%% IMU DYNAMIC ROM

%This code calculates and plots the range of motion between body coordinate
%systems of the L5 and T1 sensors.

%Inputs: Dynamic trial data and rotation matrices created during alignment process (R_bi)
%Outputs: Plots for visualization of range of motion

%Last edited by Anna Bailes 8/28/23


%% CREATE SUBJECT FOLDER

close all;clear all; clc;

subject=input('Enter Subject ID: LW_','s');
folder= strcat('P:\Lifeware Accuracy Study\Fall 23 Analysis\IMU Data\',subject);

%% LOAD INDEX FILE AND WORKING FILE

%Index file   
addpath(strcat('P:\Lifeware Accuracy Study\Data\LW_',subject,'\'));
trial=uigetfile(strcat('P:\Lifeware Accuracy Study\Data\LW_',subject,'\*.xlsx'),'Select Index File');
indeces=readtable(trial);

%Working file
trial=uigetfile(strcat('P:\Lifeware Accuracy Study\Fall 23 Analysis\Raw Data Load\',subject,'\.mat'),'Select Raw Data File');
addpath(strcat('P:\Lifeware Accuracy Study\Fall 23 Analysis\Raw Data Load\',subject,'\'));
working=importdata(trial);

%% LOAD IMU DATA AND ROTATION MATRICES

mat_T1 = uigetfile(strcat(folder,'\.mat'), 'Select T1 ALIGNMENT Matrix');
mat_L1 = uigetfile(strcat(folder,'\.mat'), 'Select L1 ALIGNMENT Matrix');
mat_L5 = uigetfile(strcat(folder,'\.mat'), 'Select L5 ALIGNMENT Matrix');
mat_Hip = uigetfile(strcat(folder,'\.mat'), 'Select Hip ALIGNMENT Matrix');

addpath(strcat('P:\Lifeware Accuracy Study\Fall 23 Analysis\IMU Data\',subject,'\'));
R_T1a_T1m = load(mat_T1); 
R_L1a_L1m = load(mat_L1); 
R_L5a_L5m = load(mat_L5); 
R_Hipa_Hipm = load(mat_Hip); 

R_T1a_T1m = R_T1a_T1m.align_T1; %Alignment matrices (measured to anatomical)
R_L1a_L1m = R_L1a_L1m.align_L1; 
R_L5a_L5m = R_L5a_L5m.align_L5; 
R_Hipa_Hipm = R_Hipa_Hipm.align_Hip; 


R_T1m_T1a = R_T1a_T1m'; %Alignment matrices (anatomical to measured)
R_L1m_L1a = R_L1a_L1m'; 
R_L5m_L5a = R_L5a_L5m'; 
R_Hipm_Hipa = R_Hipa_Hipm'; 

%% CREATE MEASURED TO GLOBAL ROTATION MATRICEX

close all

for k=1:2%:14 %change based on trial 1 or 2
startMotion=indeces{k,2};
endMotion=indeces{k,3};
trial_name=string(indeces{k,1});


R_g_T1m=[];
R_g_L1m=[];
R_L1m_g=[];
R_g_L5m=[];
R_L5m_g=[];
R_g_Hipm=[];

R_L5a_T1a=[];
R_L5a_L1a=[];
R_L5a_Hipa=[];
R_L1a_T1a=[];

T1L5_angles=[];
L1L5_angles=[];
HipL5_angles=[];
T1L1_angles=[]; 

IMU_ROM_T1L5=[];
IMU_ROM_L1L5=[];
IMU_ROM_HipL5=[];
IMU_ROM_T1L1=[]; 
  

      
% MEASURES TO GLOBAL FROM QUATERNIONS
j=1;
for i=startMotion:endMotion
    R_g_T1m(:,:,j)=quat2rotm(working.T1.quat(i,:)); 
    
    R_g_L1m(:,:,j)=quat2rotm(working.L1.quat(i,:));
    R_L1m_g(:,:,j)=R_g_L1m(:,:,j)';
    
    R_g_L5m(:,:,j)=quat2rotm(working.L5.quat(i,:));
    R_L5m_g(:,:,j)=R_g_L5m(:,:,j)';
    
    R_g_Hipm(:,:,j)=quat2rotm(working.Hip.quat(i,:)); 
    
    j=j+1;
    
end


% CREATE ROTATION MATRICES

%Calculates sensor1 anatomical wrt sensor2 anatomical

for i=1:length(R_g_T1m)
    %Prioritize axial rotation as primary angle for decomposition
    if contains(trial_name,'rot')
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
    elseif contains(trial_name,'Flex') || contains(trial_name,'Ext') || contains(trial_name,'STS')
         R_L5a_T1a(:,:,i)=R_L5a_L5m*R_L5m_g(:,:,i)*R_g_T1m(:,:,i)*R_T1m_T1a; 
         R_L5a_L1a(:,:,i)=R_L5a_L5m*R_L5m_g(:,:,i)*R_g_L1m(:,:,i)*R_L1m_L1a;  
         R_L5a_Hipa(:,:,i)=R_L5a_L5m*R_L5m_g(:,:,i)*R_g_Hipm(:,:,i)*R_Hipm_Hipa; 
         R_L1a_T1a(:,:,i)=R_L1a_L1m*R_L1m_g(:,:,i)*R_g_T1m(:,:,i)*R_T1m_T1a;  
         
    end
end


% CREATE ROTATION MATRIX AT END OF TRIAL FOR 'ZEROING'

for j=1:3;
    for i=1:3
        static_L5T1(i,j)=mean(R_L5a_T1a(i,j,end-4:end));%end-4:end)); %average across last 5 points of trial
        static_L5L1(i,j)=mean(R_L5a_L1a(i,j,end-4:end));
        static_L5Hip(i,j)=mean(R_L5a_Hipa(i,j,end-4:end));
        static_L1T1(i,j)=mean(R_L1a_T1a(i,j,end-4:end));
    end
end
    
statinv_L5T1=static_L5T1'; %take inverse of rotation matrix
statinv_L5L1=static_L5L1';
statinv_L5Hip=static_L5Hip';
statinv_L1T1=static_L1T1'; 

% RE-CALCULATE EULER ANGLES AFTER 'ZEROING'

%Calculates sensor1 anatomical wrt sensor2 anatomical

 for i=1:length(R_g_T1m)
    %Prioritize axial rotation as primary angle for decomposition
    if contains(trial_name,'rot')
         R_L5a_T1a(:,:,i)=R_L5a_L5m*R_L5m_g(:,:,i)*R_g_T1m(:,:,i)*R_T1m_T1a*statinv_L5T1; 
          T1L5_angles(i,:) = rmx2eul_xyz(R_L5a_T1a(:, :,i)); % calls function  

         R_L5a_L1a(:,:,i)=R_L5a_L5m*R_L5m_g(:,:,i)*R_g_L1m(:,:,i)*R_L1m_L1a*statinv_L5L1; 
          L1L5_angles(i,:) = rmx2eul_xyz(R_L5a_L1a(:, :,i)); % calls function  

         R_L5a_Hipa(:,:,i)=R_L5a_L5m*R_L5m_g(:,:,i)*R_g_Hipm(:,:,i)*R_Hipm_Hipa*statinv_L5Hip; 
          HipL5_angles(i,:) = rmx2eul_xyz(R_L5a_Hipa(:, :,i)); % calls function

         R_L1a_T1a(:,:,i)=R_L1a_L1m*R_L1m_g(:,:,i)*R_g_T1m(:,:,i)*R_T1m_T1a*statinv_L1T1; 
          T1L1_angles(i,:) = rmx2eul_xyz(R_L1a_T1a(:, :,i)); % calls function  
  
    %Prioritize lateral bend as primary angle for decomposition
     elseif contains(trial_name,'SB') 
    
         R_L5a_T1a(:,:,i)=R_L5a_L5m*R_L5m_g(:,:,i)*R_g_T1m(:,:,i)*R_T1m_T1a*statinv_L5T1; 
         T1L5_angles(i,:) = rmx2eul_zyx(R_L5a_T1a(:, :,i)); % calls function  

         R_L5a_L1a(:,:,i)=R_L5a_L5m*R_L5m_g(:,:,i)*R_g_L1m(:,:,i)*R_L1m_L1a*statinv_L5L1; 
          L1L5_angles(i,:) = rmx2eul_zyx(R_L5a_L1a(:, :,i)); % calls function  

         R_L5a_Hipa(:,:,i)=R_L5a_L5m*R_L5m_g(:,:,i)*R_g_Hipm(:,:,i)*R_Hipm_Hipa*statinv_L5Hip;
          HipL5_angles(i,:) = rmx2eul_zyx(R_L5a_Hipa(:, :,i)); % calls function  

         R_L1a_T1a(:,:,i)=R_L1a_L1m*R_L1m_g(:,:,i)*R_g_T1m(:,:,i)*R_T1m_T1a*statinv_L1T1; 
          T1L1_angles(i,:) = rmx2eul_zyx(R_L1a_T1a(:, :,i)); % calls function  
   
    %Prioritize flex/ext as primary angle for decomposition
     elseif contains(trial_name,'Flex') || contains(trial_name,'Ext') || contains(trial_name,'STS')
         R_L5a_T1a(:,:,i)=R_L5a_L5m*R_L5m_g(:,:,i)*R_g_T1m(:,:,i)*R_T1m_T1a*statinv_L5T1; 
          T1L5_angles(i,:) = rmx2eul_yzx(R_L5a_T1a(:, :,i)); % calls function  
    
         R_L5a_L1a(:,:,i)=R_L5a_L5m*R_L5m_g(:,:,i)*R_g_L1m(:,:,i)*R_L1m_L1a*statinv_L5L1; 
          L1L5_angles(i,:) = rmx2eul_yzx(R_L5a_L1a(:, :,i)); % calls function  
    
         R_L5a_Hipa(:,:,i)=R_L5a_L5m*R_L5m_g(:,:,i)*R_g_Hipm(:,:,i)*R_Hipm_Hipa*statinv_L5Hip; 
         HipL5_angles(i,:) = rmx2eul_yzx(R_L5a_Hipa(:, :,i)); % calls function

         R_L1a_T1a(:,:,i)=R_L1a_L1m*R_L1m_g(:,:,i)*R_g_T1m(:,:,i)*R_T1m_T1a*statinv_L1T1; 
          T1L1_angles(i,:) = rmx2eul_yzx(R_L1a_T1a(:, :,i)); % calls function 

     end
 end
     
% UNWRAPPING AND CONVERT TO DEGREES

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

for i=1:length(R_g_T1m)
    IMU_ROM_T1L5(i, :) = rad2deg(T1L5_angles(i, :)); 
    IMU_ROM_L1L5(i, :) = rad2deg(L1L5_angles(i, :)); 
    IMU_ROM_HipL5(i, :) = rad2deg(HipL5_angles(i, :));
    IMU_ROM_T1L1(i, :) = rad2deg(T1L1_angles(i, :)); 
end

% PLOT ROM

index=1; %look at graph first and then fill in with index of start of movement

IMU_ROM_T1L5=IMU_ROM_T1L5(index:end,:);
IMU_ROM_L1L5=IMU_ROM_L1L5(index:end,:);
IMU_ROM_HipL5=IMU_ROM_HipL5(index:end,:);
IMU_ROM_T1L1=IMU_ROM_T1L1(index:end,:);

%Axial Rotation Plots-xyz
if contains(trial_name,'rot')
    figure()
    subplot(411);hold on
    plot(IMU_ROM_T1L5);
    title('T1L5angles')
    ylabel('Degrees'); title('T1L5 Range of Motion');
    legend('AxRot','FlexExt','LatBend')

    subplot(412);hold on
    plot(IMU_ROM_L1L5);
    title('L1L5angles')
    legend('AxRot','FlexExt','LatBend')
    ylabel('Degrees'); title('Lumbar Range of Motion');

    subplot(413);hold on
    plot(IMU_ROM_HipL5);
    title('HipL5angles')
    legend('AxRot','FlexExt','LatBend')
    ylabel('Degrees'); title('Hip Range of Motion');
    hold off;

    subplot(414);hold on
    plot(IMU_ROM_T1L1);
    title('T1L1angles')
    legend('AxRot','FlexExt','LatBend')
    ylabel('Degrees'); title('Thoracic Range of Motion');
    hold off;
    sgtitle(convertCharsToStrings(trial_name))

%     saveas(gcf,strcat(folder,'\',trial_name,'.jpeg'));

%Lateral Bend Plots-zyx
    elseif contains(trial_name,'SB') 
    figure()
    subplot(411);hold on
    plot(IMU_ROM_T1L5);
    title('T1L5angles');
    legend('LatBend','FlexExt','AxRot');
    ylabel('Degrees'); title('T1L5 Range of Motion');

    subplot(412);hold on
    plot(IMU_ROM_L1L5);
    title('L1L5angles');
    legend('LatBend','FlexExt','AxRot');
    ylabel('Degrees'); title('Lumbar Range of Motion');

    subplot(413);hold on
    plot(IMU_ROM_HipL5);
    title('HipL5angles');
    legend('LatBend','FlexExt','AxRot');
    ylabel('Degrees'); title('Hip Range of Motion');
    hold off;

    subplot(414);hold on
    plot(IMU_ROM_T1L1);
    title('T1L1angles');
    legend('LatBend','FlexExt','AxRot');
    ylabel('Degrees'); title('Thoracic Range of Motion');
    hold off;
    sgtitle(convertCharsToStrings(trial_name))

%     saveas(gcf,strcat(folder,'\',trial_name,'.jpeg'));

%Flexion Extension Plots-yzx
    elseif contains(trial_name,'Flex') || contains(trial_name,'Ext') || contains(trial_name,'STS')
    figure()
    subplot(411);hold on
    plot(IMU_ROM_T1L5);
    legend('FlexExt','LatBend','AxRot')
    ylabel('Degrees'); title('T1L5 Range of Motion');

    subplot(412);hold on
    plot(IMU_ROM_L1L5);
    legend('FlexExt','LatBend','AxRot')
    ylabel('Degrees'); title('Lumbar Range of Motion');

    subplot(413);hold on
    plot(IMU_ROM_HipL5);
    legend('FlexExt','LatBend','AxRot')
    ylabel('Degrees'); title('Hip Range of Motion');
    hold off;

    subplot(414);hold on
    plot(IMU_ROM_T1L1);
    legend('FlexExt','LatBend','AxRot')
    ylabel('Degrees'); title('Thoracic Range of Motion');
    hold off;
    sgtitle(convertCharsToStrings(trial_name))

%     saveas(gcf,strcat(folder,'\',trial_name,'.jpeg'));
end

%SAVE ROM DATA

folder= strcat('P:\lifeware Accuracy Study\Fall 23 Analysis\IMU Data\',subject);
mkdir(folder)
filename=strcat(folder,'\',subject,'_IMU_',trial_name,'_ROM.mat');
save(filename,'IMU_ROM_T1L5','IMU_ROM_L1L5','IMU_ROM_HipL5','IMU_ROM_T1L1');
 
end
