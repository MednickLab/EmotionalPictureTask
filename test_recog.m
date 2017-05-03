function test_recog(studyID,subjectID,visitID,testID)%Take human input to decide which version to run and what session
%if 1 %to run not as a function
%Runs a testing session of the IFT task.
%Test data is pulled from a participants file
%Images are displayed (both trained and foils), and the user must pick a level of familarity
%@Params: studyID - Name of study (to load setting file)
%@Params: subjectID - Unique subject number
%@Params: testID - which test to run (first, second etc)
%@Author: Ben Yetton
%@Property: Mednick Lab, UC Riverside
%@Date Created: 15/1/15
try
Screen('Preference', 'SkipSyncTests', 1);
%studyID='EPT_PSTIM1'; subjectID=1; testID=2; visitID=1; sessionID = 1; %to run not as a function

speedup = 1;

try 
    settings = csvimport(sprintf('Study_Settings_%s.csv',studyID),'outputAsChar',true);
    useImages= str2double(settings{3,strcmp(settings(1,:),'useImages')}); 
    testBetweenStimDuration = str2double(settings{3,strcmp(settings(1,:),'testBetweenStimDuration')}); 
    testStimDuration = str2double(settings{3,strcmp(settings(1,:),'testStimDuration')});
    testInstructBlurb = settings{3,strcmp(settings(1,:),'testInstructBlurb')};
    acceptableAns = settings(3:end,strcmp(settings(1,:),'acceptableTestAns'));
    acceptableAns = acceptableAns(~cellfun('isempty',acceptableAns)); %remove any empty cells (artifact of bad csv import)
    testInitBlurb = settings{3,strcmp(settings(1,:),sprintf('test%iInitBlurb',testID))};
catch err
    menu('ERROR: The settings file for this study is not found or has been corrupted','Quit');
    rethrow(err)
end

parData = load(sprintf('Data/Incomplete/%s_Sub%i_Visit%i',studyID,subjectID,visitID));
stimTest = parData.(sprintf('stimTest%i',testID));

%arrays to save
responseArray = cell(length(stimTest),1);
rtArray = cell(length(stimTest),1);

%now we display random words using psycotoolbox

%% boilerplate display settings
ListenChar(2);
HideCursor;
KbName('UnifyKeyNames');
GetSecs;
FlushEvents('keyDown');

%% screen info
[xResolution, yResolution] = Screen('WindowSize',0);
cx = xResolution/2;
cy = yResolution/2;
backColor = 255;
textColor=0;
w = Screen(0,'OpenWindow',backColor);
Screen('GetFlipInterval', w, 100, 0.00005, 3);
Screen(w, 'TextFont', 'Arial');
Screen( w, 'TextSize', 18);

imageSize = 300;
imageRect = [];
sideoffset=220;
imageCenterRect = [cx-imageSize/2,cy-imageSize/2,cx+imageSize/2,cy+imageSize/2];
imageLeftRect = [cx-imageSize/2-sideoffset,cy-imageSize/2,cx+imageSize/2-sideoffset,cy+imageSize/2];
imageRightRect = [cx-imageSize/2+sideoffset,cy-imageSize/2,cx+imageSize/2+sideoffset,cy+imageSize/2];

% show instructions
Screen(w,'FillRect',backColor);
DrawFormattedText(w, testInitBlurb,'center','center',textColor);

instructString = 'Please wait for the experimenter to continue...';
boundRect = Screen('TextBounds', w, instructString);
Screen('drawtext',w,instructString, cx-boundRect(3)/2, cy-boundRect(4)/5+220, textColor);
Screen('Flip',w);

while(1) % wait for space bar
    FlushEvents('keyDown');
    temp = GetChar;
    if (temp == 's')
        break;
    elseif (temp == '=')
        speedup = 100;
        break;
    end
end
Screen('Flip',w); %Changes to next screen

[stimRows,stimCols] = size(stimTest);
if useImages
    imageTextures = cell(size(stimTest));
    %pre load image textures (out of main loop to save cpu power in main loop)
    for i=1:stimRows
        if stimCols==1
            imageTextures{i} = Screen('MakeTexture',w,imread(stimTest{i}));
        else
            imageTextures{i,1} = Screen('MakeTexture',w,imread(stimTest{i,1}));
            imageTextures{i,2} = Screen('MakeTexture',w,imread(stimTest{i,2}));
        end
    end
end

% recall words
for trial=1:length(stimTest)
    FlushEvents('keyDown');
    %check if this is a familar item or not
    if useImages
        if stimCols==2
            Screen('DrawTexture', w, imageTextures{trial,1},[], imageLeftRect);
            Screen('DrawTexture', w, imageTextures{trial,2},[], imageRightRect);
        else
            Screen('DrawTexture', w, imageTextures{trial},[], imageCenterRect);
        end
    else %pictures
        Screen( w, 'TextSize', 42);
        if stimCols==2
            DrawFormattedText(w,sprintf('%s\n\n%s',stimTest{trial,1},stimTest{trial,2}),'center','center',[0 0 0]);
        else
            DrawFormattedText(w,stimTest{trial},'center','center',[0 0 0]);
        end
        Screen( w,'TextSize', 18);
    end
    
    %draw response key
    DrawFormattedText(w, testInstructBlurb,'center', cy+imageSize/2+50,textColor);
    FlushEvents('keyDown'); %clear keybuffer
    timeShow = Screen('Flip',w);
    DrawFormattedText(w, testInstructBlurb,'center', cy+imageSize/2+50,textColor);
    Screen('Flip',w,timeShow+testStimDuration)
    while(1) % wait for user input
        ch = GetChar;
        if(ismember(ch,acceptableAns))
            responseArray{trial} = ch;
            %wait a bit between images
            timeComplete = Screen('Flip',w);
            WaitSecs(testBetweenStimDuration/speedup);
            rtArray{trial} = timeComplete-timeShow;
            break
        end
    end
end

instructString = 'Thank you. You have now finished testing';
boundRect = Screen('TextBounds', w, instructString);
Screen('drawtext',w,instructString, cx-boundRect(3)/2, cy-boundRect(4)/5+200, textColor);
Screen('Flip',w);
WaitSecs(2)

%training finished sucessfully so save the responselist...
%form some variable names based on test session...
rtArrayName = sprintf('rtArray%i',testID);
responseArrayName = sprintf('responseArray%i',testID);

%depending on the session id we will ither add the first training data or
%add more training data to exisiting data from test session 1
parData.(responseArrayName) = responseArray;
parData.(rtArrayName) = rtArray;
save(sprintf('Data/Incomplete/%s_Sub%i_Visit%i',studyID,subjectID,visitID),'-struct','parData');
struct2csv(parData,sprintf('Data/Incomplete/%s_Sub%i_Visit%i_Test%iData.csv',studyID,subjectID,visitID,testID))

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
