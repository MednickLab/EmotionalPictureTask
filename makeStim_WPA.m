function makeStim_WPA(studyID,subjectID,visitID)

%if 1 %to run not as a function
%clear
%Runs the training words/images pairs of the WPA/PPT/EPT tasks for all studys.
%Images data are pulled from the corresponding folder to imageListID
%words are pulled from worlist csv file
%Stims are randomised and displayed on screen using psychtoolbox
%@Author: Ben Yetton
%@Property: Mednick Lab, UC Riverside
%@Date Created: 15/1/15

try %try/catch for clean kill
%studyID='WPA_ACH0'; subjectID=999; visitID=1;%to run not as a function
%studyID='ACETYLCHOL1'; subjectID=1; wordListID=1;visitID=1; %to run not as a function
%seed random num generator
seed = sum(100*clock);
rand('seed',seed);

%load study settings
try 
    settings = csvimport(sprintf('Study_Settings_%s.csv',studyID),'outputAsChar',true);
    numReps = str2double(settings{3,strcmp(settings(1,:),'numRepetitions')}); 
catch err
    menu('The settings file or images folder for this study is not found or has been corrupted','Quit');
    fclose('all');
    rethrow(err)
end

%Get the wordlist number we need to load from the counterballence
counterbalance = csvimport(sprintf('CounterBalance_%s.csv',studyID),'outputAsChar',true);
%stimlistID = counterbalance(strcmp(counterbalance(:,1),num2str(subjectID)),strcmp(counterbalance(1,:),sprintf('visit%i',visitID)));
subjectIndex = strcmp(counterbalance(:,1),num2str(subjectID));

%Get the words from wordlist
stimlists = csvimport(sprintf('Wordlist_%s.csv',studyID));

%primacy and recencys
primRecListNum = counterbalance(subjectIndex,strcmp(counterbalance(1,:),sprintf('V%i_PrimRec',visitID)));
stimPrimRec = stimlists(2:end,strcmp(stimlists(1,:),primRecListNum));
stimPrimRec = stimPrimRec(~cellfun('isempty',stimPrimRec(:,1)),:); %remove any empty cells (artifact of bad csv import)
stimPrimRec = shuffle(stimPrimRec')';
[stimRecency,stimPrimacy] = half(stimPrimRec);

stimEnImmIntactListNum = counterbalance(subjectIndex,strcmp(counterbalance(1,:),sprintf('V%i_Encoding_ImmIntact',visitID)));
stimEnImmIntact = stimlists(2:end,strcmp(stimlists(1,:),stimEnImmIntactListNum));
stimEnImmIntact = stimEnImmIntact(~cellfun('isempty',stimEnImmIntact(:,1)),:); %remove any empty cells (artifact of bad csv import)
%stimEnImmIntact(:,3) = {'EnImmIntact'};
%no need for shuffle

stimEnImmRearrListNum = counterbalance(subjectIndex,strcmp(counterbalance(1,:),sprintf('V%i_Encoding_ImmRearr',visitID)));
stimEnImmRearr = stimlists(2:end,strcmp(stimlists(1,:),stimEnImmRearrListNum));
stimEnImmRearr = stimEnImmRearr(~cellfun('isempty',stimEnImmRearr(:,1)),:); %remove any empty cells (artifact of bad csv import)
%stimEnImmRearr(:,3) = {'EnImmRearr'};
%no need for shuffle

stimEnDelIntactListNum = counterbalance(subjectIndex,strcmp(counterbalance(1,:),sprintf('V%i_Encoding_DelIntact',visitID)));
stimEnDelIntact = stimlists(2:end,strcmp(stimlists(1,:),stimEnDelIntactListNum));
stimEnDelIntact = stimEnDelIntact(~cellfun('isempty',stimEnDelIntact(:,1)),:); %remove any empty cells (artifact of bad csv import)
%stimEnDelIntact(:,3) = {'EnDelIntact'};
%no need for shuffle

stimEnDelRearrListNum = counterbalance(subjectIndex,strcmp(counterbalance(1,:),sprintf('V%i_Encoding_DelRearr',visitID)));
stimEnDelRearr = stimlists(2:end,strcmp(stimlists(1,:),stimEnDelRearrListNum));
stimEnDelRearr = stimEnDelRearr(~cellfun('isempty',stimEnDelRearr(:,1)),:); %remove any empty cells (artifact of bad csv import)
%stimEnDelRearr(:,3) = {'EnDelRearr'};

stimImmRearrListNum = counterbalance(subjectIndex,strcmp(counterbalance(1,:),sprintf('V%i_ImmTest_Rearr',visitID)));
stimImmRearr = stimlists(2:end,strcmp(stimlists(1,:),stimImmRearrListNum));
stimImmRearr = stimImmRearr(~cellfun('isempty',stimImmRearr(:,1)),:); %remove any empty cells (artifact of bad csv import)
stimImmRearr(:,3) = {'Rearr'};

stimImmIntactListNum = counterbalance(subjectIndex,strcmp(counterbalance(1,:),sprintf('V%i_ImmTest_Intact',visitID)));
stimImmIntact = stimlists(2:end,strcmp(stimlists(1,:),stimImmIntactListNum));
stimImmIntact = stimImmIntact(~cellfun('isempty',stimImmIntact(:,1)),:); %remove any empty cells (artifact of bad csv import)
stimImmIntact(:,3) = {'Intact'};

stimImmNovelListNum = counterbalance(subjectIndex,strcmp(counterbalance(1,:),sprintf('V%i_ImmTest_Novel',visitID)));
stimImmNovel = stimlists(2:end,strcmp(stimlists(1,:),stimImmNovelListNum));
stimImmNovel = stimImmNovel(~cellfun('isempty',stimImmNovel(:,1)),:); %remove any empty cells (artifact of bad csv import)
stimImmNovel(:,3) = {'Novel'};

stimDelRearrListNum = counterbalance(subjectIndex,strcmp(counterbalance(1,:),sprintf('V%i_DelTest_Rearr',visitID)));
stimDelRearr = stimlists(2:end,strcmp(stimlists(1,:),stimDelRearrListNum));
stimDelRearr = stimDelRearr(~cellfun('isempty',stimDelRearr(:,1)),:); %remove any empty cells (artifact of bad csv import)
stimDelRearr(:,3) = {'Rearr'};

stimDelIntactListNum = counterbalance(subjectIndex,strcmp(counterbalance(1,:),sprintf('V%i_DelTest_Intact',visitID)));
stimDelIntact = stimlists(2:end,strcmp(stimlists(1,:),stimDelIntactListNum));
stimDelIntact = stimDelIntact(~cellfun('isempty',stimDelIntact(:,1)),:); %remove any empty cells (artifact of bad csv import)
stimDelIntact(:,3) = {'Intact'};

stimDelNovelListNum = counterbalance(subjectIndex,strcmp(counterbalance(1,:),sprintf('V%i_DelTest_Novel',visitID)));
stimDelNovel = stimlists(2:end,strcmp(stimlists(1,:),stimDelNovelListNum));
stimDelNovel = stimDelNovel(~cellfun('isempty',stimDelNovel(:,1)),:); %remove any empty cells (artifact of bad csv import)
stimDelNovel(:,3) = {'Novel'};

stimEncoding = shuffle([stimEnImmIntact; stimEnDelIntact; stimEnImmRearr; stimEnDelRearr]);
stimTest1 = shuffle([stimImmIntact ; stimImmRearr ; stimImmNovel]);
stimTest2 = shuffle([stimDelIntact ; stimDelRearr ; stimDelNovel]);

%create repitions of middle if nessary
shuffleMiddle = [];
for i = 1:numReps %create famil repitition if required
    shuffleTemp = randperms(length(stimEncoding),length(stimEncoding)); %shuffle array and repeat for reps needed
    shuffleMiddle = [shuffleMiddle shuffleTemp];
end
stimTraining = [stimPrimacy ; stimEncoding(shuffleMiddle,:) ; stimRecency]; %samwitch between primacy and recency 

%training finished sucessfully so save the training data
save(sprintf('Data/Incomplete/%s_Sub%i_Visit%i',studyID,subjectID,visitID),...
    'stimTraining','stimEncoding',...
    'stimTest2','stimTest1');

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
