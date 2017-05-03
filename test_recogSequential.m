function test_recogSequential(studyID,subjectID,visitID,testID)%Take human input to decide which version to run and what session
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
%% 
try

%studyID='WPA_ACH0'; subjectID=1; testID=1; visitID=0; %to run not as a function

speedup = 1;


try 
    settings = csvimport(sprintf('Study_Settings_%s.csv',studyID),'outputAsChar',true);
    useImages= str2double(settings{3,strcmp(settings(1,:),'useImages')});
    crossOn= str2double(settings{3,strcmp(settings(1,:),'crossOn')});
    testBetweenStimDuration = str2double(settings{3,strcmp(settings(1,:),'testBetweenStimDuration')});
    testStimDuration = str2double(settings{3,strcmp(settings(1,:),'testStimDuration')});
    testCue1Duration = str2double(settings{3,strcmp(settings(1,:),'testCue1Duration')});
    testCue2DurationBase = str2double(settings{3,strcmp(settings(1,:),'testCue2DurationBase')});
    testCue2DurationRange = str2double(settings{3,strcmp(settings(1,:),'testCue2DurationRange')});
    testResponseDuration = str2double(settings{3,strcmp(settings(1,:),'testResponseDuration')});
    testBlinkDuration = str2double(settings{3,strcmp(settings(1,:),'testBlinkDuration')});
    acceptableAns = settings(3:end,strcmp(settings(1,:),'acceptableTestAns'));
    acceptableAns = acceptableAns(~cellfun('isempty',acceptableAns)); %remove any empty cells (artifact of bad csv import)
    testInitBlurb = settings(3:end,strcmp(settings(1,:),sprintf('test%iInitBlurb',testID)));
    testInitBlurb = testInitBlurb(~cellfun('isempty',testInitBlurb)); %remove any empty cells (artifact of bad csv import)
catch err
    menu('ERROR: The settings file for this study is not found or has been corrupted','Quit');
    rethrow(err)
end

parData = load(sprintf('Data/Incomplete/%s_Sub%i_Visit%i',studyID,subjectID,visitID));
stimTest = parData.(sprintf('stimTest%i',testID));

%arrays to save
responseArray = cell(length(stimTest),1);
rtArray = cell(length(stimTest),1);
responseTimeArray = cell(length(stimTest),1);

%now we display random words using psycotoolbox

%% boilerplate display settings
ListenChar(2);
HideCursor;
KbName('UnifyKeyNames');
FlushEvents('keyDown');

%% screen info
[xResolution, yResolution] = Screen('WindowSize',0);
cx = xResolution/2;
cy = yResolution/2;
backColor = 0;
textColor=255;
[w,windowRect] = Screen(0,'OpenWindow',backColor);
slack = Screen('GetFlipInterval', w, 100, 0.00005, 3);
Screen(w, 'TextFont', 'Arial');
Screen( w, 'TextSize', 18);

imageSize = 300;
imageRect = [];
sideoffset=220;
imageCenterRect = [cx-imageSize/2,cy-imageSize/2,cx+imageSize/2,cy+imageSize/2];
imageLeftRect = [cx-imageSize/2-sideoffset,cy-imageSize/2,cx+imageSize/2-sideoffset,cy+imageSize/2];
imageRightRect = [cx-imageSize/2+sideoffset,cy-imageSize/2,cx+imageSize/2+sideoffset,cy+imageSize/2];

fixCrossDimPix = 10;
fixXCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
fixYCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
fixAllCoords = [fixXCoords; fixYCoords];
fixLineWidthPix = 2;

bigCrossXCoords = [-cx cx 0 0];
bigCrossYCoords = [0 0 -cy cy];
bigCrossAllCoords = [bigCrossXCoords; bigCrossYCoords];
bigCrossLineWidthPix = 1;
bigCrossDarkness =50;  %210;
bigCrossColor = [bigCrossDarkness bigCrossDarkness bigCrossDarkness];

% show instructions
Screen(w,'FillRect',backColor);
DrawFormattedText(w, testInitBlurb{1},'center','center',textColor);

instructString = 'Please spacebar to continue...';
boundRect = Screen('TextBounds', w, instructString);
Screen('drawtext',w,instructString, cx-boundRect(3)/2, cy-boundRect(4)/5+220, textColor);
Screen('Flip',w);

while(1) % wait for space bar
    FlushEvents('keyDown');
    temp = GetChar;
    if (temp == ' ')
        break;
    end
end

Screen(w,'FillRect',backColor);
DrawFormattedText(w, testInitBlurb{2},'center','center',textColor);

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


[stimRows,stimCols] = size(stimTest);
if useImages
    imageTextures = cell(size(stimTest));
    %pre load image textures (out of main loop to save cpu power in main loop)
    for i=1:stimRows
        imageTextures{i,1} = Screen('MakeTexture',w,imread(stimTest{i,1}));
        imageTextures{i,2} = Screen('MakeTexture',w,imread(stimTest{i,2}));
    end
end

% recall words
blinkOnset = Screen('Flip',w); %Changes to next screen
initTime = blinkOnset;
for trial=1:length(stimTest)
    %draw fixation cross
    if (crossOn)
        Screen('DrawLines', w, bigCrossAllCoords, bigCrossLineWidthPix, bigCrossColor, [cx cy]);
    end
    Screen('DrawLines', w, fixAllCoords, fixLineWidthPix, [255 255 255], [cx cy]);
    cue1Time = Screen('Flip',w,blinkOnset+testBlinkDuration-slack/2);
    
    %draw green fixation cross
    if (crossOn)
        Screen('DrawLines', w, bigCrossAllCoords, bigCrossLineWidthPix, bigCrossColor, [cx cy]);
    end
    Screen('DrawLines', w, fixAllCoords, fixLineWidthPix, [255 0 0], [cx cy]);
    cue2Onset = Screen('Flip',w,cue1Time+testCue1Duration/speedup-slack/2); %wait for cue 1
    
    %draw pair 1
    if (crossOn)
        Screen('DrawLines', w, bigCrossAllCoords, bigCrossLineWidthPix, bigCrossColor, [cx cy]);
    end
    if useImages
        Screen('DrawTexture', w, imageTextures{trial,1},[], imageCenterRect);
    else %pictures
        Screen( w, 'TextSize', 36);
        boundRect = Screen('TextBounds', w, stimTest{trial,1});
        Screen('drawtext',w,stimTest{trial,1}, cx-boundRect(3)/2, cy-boundRect(4)/2-5, textColor);
        Screen( w,'TextSize', 18);
    end
    
    jitteredCue2 = testCue2DurationBase+testCue2DurationRange*rand(1);
    stim1Onset = Screen('Flip',w,cue2Onset+jitteredCue2/speedup-slack/2); %show word 1
    
    if (crossOn)
        Screen('DrawLines', w, bigCrossAllCoords, bigCrossLineWidthPix, bigCrossColor, [cx cy]);
    end
    betweenStimOnset = Screen('Flip',w,stim1Onset+testStimDuration/speedup-slack/2); %blankness snown
    
    if (crossOn)
        Screen('DrawLines', w, bigCrossAllCoords, bigCrossLineWidthPix, bigCrossColor, [cx cy]);
    end

    %draw pair 2
    if useImages
        Screen('DrawTexture', w, imageTextures{trial,2},[], imageCenterRect);
    else %pictures
        Screen( w, 'TextSize', 36);
        boundRect = Screen('TextBounds', w, stimTest{trial,2});
        Screen('drawtext',w,stimTest{trial,2}, cx-boundRect(3)/2, cy-boundRect(4)/2-5, textColor);
        Screen( w,'TextSize', 18);
    end
    
    stim2Onset = Screen('Flip',w,betweenStimOnset+testBetweenStimDuration/speedup-slack/2); %word 2 shown

    %flip and wait for response
    FlushEvents('keyDown');
    if (crossOn)
        Screen('DrawLines', w, bigCrossAllCoords, bigCrossLineWidthPix, bigCrossColor, [cx cy]);
    end
    responseOnset = Screen('Flip',w,stim2Onset+testStimDuration/speedup-slack/2);
    FlushEvents('keyDown');
    while((GetSecs-responseOnset) < testResponseDuration/speedup) % wait for user input
        [keyIsDown, timeKeypress, keyCode] = KbCheck();    
        if keyIsDown
            FlushEvents('keyDown');
            key = KbName(keyCode);
            key = key(1); %handle both numpad and other number key by stripping extra identifier
            if(ismember(key,acceptableAns))
                break %cool got correct key, so break out of this loopy loopski
            end
        end
        key = '0'; %if the user does not respond
        timeKeypress = GetSecs();
    end
    %save response
    responseArray{trial} = key(1);
    rtArray{trial} = timeKeypress-responseOnset;
    responseTimeArray{trial} = timeKeypress - initTime;
    
    %blink break!
    %wait a bit between images
    if (crossOn)
        Screen('DrawLines', w, bigCrossAllCoords, bigCrossLineWidthPix, bigCrossColor, [cx cy]);
    end
    blinkOnset = Screen('Flip',w); %show blink break right after response
    
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
responseTimeArrayName = sprintf('responseTimeArray%i',testID);

%depending on the session id we will ither add the first training data or
%add more training data to exisiting data from test session 1
parData.(responseArrayName) = responseArray;
parData.(rtArrayName) = rtArray;
parData.(responseTimeArrayName) = responseTimeArray;
save(sprintf('Data/Incomplete/%s_Sub%i_Visit%i',studyID,subjectID,visitID),'-struct','parData');
try
struct2csv(parData,sprintf('Data/Incomplete/%s_Sub%i_Visit%i_Test%iData.csv',studyID,subjectID,visitID,testID))
catch
    ;
end


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
