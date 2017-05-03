function makeStim_EPT(studyID,subjectID,visitID,stimListID)
%if 1 %to run not as a function
%Example of a function to create stim lists of an emoitional memory task. This could be modified for any types of images.
%Stim data is saved to the stim file for that subject (in Data/Incomplete/*)
%Images data are pulled from the corresponding folder to imageListID
%Stims are randomised and displayed on screen using psychtoolbox
%@Author: Ben Yetton
%@Property: Mednick Lab, UC Riverside
%@Date Created: 15/1/15

try %try/catch for clean kill
%studyID='EPT_PSTIM1'; subjectID=1; stimListID=2;visitID=1;%to run not as a function

%seed random num generator
seed = sum(100*clock); %alternativly this could be seeded from subject ID for repeatable experiments
rand('seed',seed);
 
%load study settings
try 
    settings = csvimport(sprintf('Study_Settings_%s.csv',studyID),'outputAsChar',true);
    numReps = str2double(settings{3,strcmp(settings(1,:),'numRepetitions')});
    numPrimacy = str2double(settings{3,strcmp(settings(1,:),'numPrimacy')});
    numRecency = str2double(settings{3,strcmp(settings(1,:),'numRecency')});
    numStimTrainPerValence = str2double(settings(3,strcmp(settings(1,:),'numTrainStimFromEachValence')));
catch err
    menu('The settings file or images folder for this study is not found or has been corrupted','Quit');
    fclose('all');
    rethrow(err)
end

%create image lists
imageListDirectory = sprintf('Images/ImageList%i/',stimListID);

%load neu im files
imFiles = dir([imageListDirectory 'Neu/*.jpg']);
stimNeu = {imFiles.name};
stimNeu = strcat(imageListDirectory,strcat('Neu/',stimNeu));
stimNeu = shuffle(stimNeu)'; %random shuffle inputs 

%split into stim arrays
%Prim and Rec images are neutral
stimPrimacy = stimNeu(1:numPrimacy);
stimRecency = stimNeu((numPrimacy+1):(numPrimacy+numRecency)); 

stimFamilNeu = stimNeu((numPrimacy+numRecency+1):(numStimTrainPerValence/2+numPrimacy+numRecency));
stimFoilNeu = stimNeu((numStimTrainPerValence/2+numPrimacy+numRecency+1):(numStimTrainPerValence+numPrimacy+numRecency));
[stimNeuFamilTest1,stimNeuFamilTest2] = half(stimFamilNeu);
[stimNeuFoilTest1,stimNeuFoilTest2] = half(stimFoilNeu);

%load neg im files
imFiles = dir([imageListDirectory 'Neg/*.jpg']);
stimNeg = {imFiles.name};
stimNeg = strcat(imageListDirectory,strcat('Neg/',stimNeg));
stimNeg = shuffle(stimNeg)'; %random shuffle inputs 
%split into stim arrays
stimFamilNeg = stimNeg(1:(numStimTrainPerValence/2));
stimFoilNeg = stimNeg((numStimTrainPerValence/2+1):numStimTrainPerValence);
[stimNegFamilTest1,stimNegFamilTest2] = half(stimFamilNeg);
[stimNegFoilTest1,stimNegFoilTest2] = half(stimFoilNeg);

stimMiddle = shuffle([stimNegFamilTest1 ; stimNegFamilTest2 ; stimNeuFamilTest1 ; stimNeuFamilTest2]);
stimTest1 = shuffle([stimNegFamilTest1 ; stimNeuFamilTest1 ; stimNegFoilTest1 ; stimNeuFoilTest1]);
stimTest2 = shuffle([stimNegFamilTest2 ; stimNeuFamilTest2 ; stimNegFoilTest2 ; stimNeuFoilTest2]);
stimFoil = [stimFoilNeg ; stimFoilNeu];
stimFamil = [stimFamilNeg ; stimFamilNeu];

stimTraining = [stimPrimacy ; stimMiddle ; stimRecency]; %samwitch between primacy and recency 

%Save the stim data
save(sprintf('Data/Incomplete/%s_Sub%i_Visit%i',studyID,subjectID,visitID),...
    'stimListID','stimTraining','stimTest1','stimTest2','stimRecency','stimPrimacy',...
    'stimNeg','stimNeu','stimFamil','stimFoil');

%save to csv
parData = load(sprintf('Data/Incomplete/%s_Sub%i_Visit%i',studyID,subjectID,visitID));
struct2csv(parData,sprintf('Data/Incomplete/%s_Sub%i_Visit%i_TrainingData.csv',studyID,subjectID,visitID)) 

%clean up and go home 
ListenChar(1);
ShowCursor;
sca;
fclose('all');
catch err
    ListenChar(1);
    ShowCursor;
    sca;
    fclose('all');
    rethrow(err)
end
end
