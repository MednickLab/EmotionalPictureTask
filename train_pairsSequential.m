function train_pairsSequential(studyID,subjectID,visitID)
%if 1 %to run not as a function
%clear
%Runs the training words/images pairs of the WPA/PPT/EPT tasks for all studys.
%Images data are pulled from the corresponding folder to imageListID
%words are pulled from worlist csv file
%Stims are randomised and displayed on screen using psychtoolbox
%@Author: Ben Yetton
%@Property: Mednick Lab, UC Riverside
%@Date Created: 15/1/15
 
seed = sum(100*clock);
rand('seed',seed);

%%
Screen('Preference', 'SkipSyncTests', 1);
try %try/catch for clean kill
%studyID='WPA_ACH0'; subjectID=1; visitID=0;%to run not as a function
%studyID='WPA1'; subjectID=1; stimListID=2;visitID=1; sessionID=1;%to run not as a function
%studyID='ACETYLCHOL1'; subjectID=1; wordListID=1;visitID=1; %to run not as a function
%seed random num generator
seed = sum(100*clock);
rand('seed',seed);

speedup = 1; % acceleration factor for debugging (default=1)

%load study settings
try 
    settings = csvimport(sprintf('Study_Settings_%s.csv',studyID),'outputAsChar',true);
    crossOn= str2double(settings{3,strcmp(settings(1,:),'crossOn')});
    trainBetweenStimDuration = str2double(settings{3,strcmp(settings(1,:),'trainBetweenStimDuration')});
    trainBetweenPairDuration = str2double(settings{3,strcmp(settings(1,:),'trainBetweenPairDuration')}); 
    trainStimDuration = str2double(settings{3,strcmp(settings(1,:),'trainStimDuration')});
    trainCue1Duration = str2double(settings{3,strcmp(settings(1,:),'trainCue1Duration')});
    trainCue2DurationBase = str2double(settings{3,strcmp(settings(1,:),'trainCue2DurationBase')});
    trainCue2DurationRange = str2double(settings{3,strcmp(settings(1,:),'trainCue2DurationRange')});
    trainBlinkDuration = str2double(settings{3,strcmp(settings(1,:),'trainBlinkDuration')});
    useImages= str2double(settings{3,strcmp(settings(1,:),'useImages')}); 
    trainBlurb = settings{3,strcmp(settings(1,:),'trainBlurb')};
    numBreaks = str2double(settings{3,strcmp(settings(1,:),'numBreaks')});
catch err
    menu('The settings file or images folder for this study is not found or has been corrupted','Quit');
    fclose('all');
    rethrow(err)
end

%%
%load par data (or try anyways)
parData = load(sprintf('Data/Incomplete/%s_Sub%i_Visit%i',studyID,subjectID,visitID));
 
%%We now have all out stim setup so can start psychtoolbox
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
backColor = 0;
textColor=255;
[w,windowRect]= Screen(0,'OpenWindow',backColor);%,ScreenRect,32);
slack = Screen('GetFlipInterval', w, 100, 0.00005, 3)/2;
Screen(w, 'TextFont', 'Arial');
Screen( w, 'TextSize', 18);  

% [xCenter, yCenter] = RectCenter(windowRect);
% baseRect = [0 0 100 100];
% % centeredRect = CenterRectOnPointd(baseRect, xCenter-950, yCenter+530 );
% centeredRect = CenterRectOnPointd(baseRect, xCenter+100, yCenter+100);

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
bigCrossDarkness =50;   %210;
bigCrossColor = [bigCrossDarkness bigCrossDarkness bigCrossDarkness];

%now we display random images using psycotoolbox
% show instructions
Screen(w,'FillRect',backColor);
DrawFormattedText(w, trainBlurb,'center','center',textColor);

instructString = 'Please wait for the experimenter to continue...';
boundRect = Screen('TextBounds', w, instructString);
Screen('drawtext',w,instructString, cx-boundRect(3)/2, cy-boundRect(4)/5+200, textColor);
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

%load image textures (out of main loop to save cpu power in main loop)
if useImages
    imageTextures = cell(size(parData.stimTraining));
    try 
        for i=1:length(parData.stimTraining)
            imageTextures{i,1} = Screen('MakeTexture',w,imread(parData.stimTraining{i,1}));
            imageTextures{i,2} = Screen('MakeTexture',w,imread(parData.stimTraining{i,2}));
        end
    catch err
        disp('Error in loading images');
        fclose('all');
        rethrow(err)
    end
end

%Reset all counters
FlushEvents('keyDown');
Screen(w, 'TextSize', 36);
Screen(w,'FillRect',backColor);
blinkOnset = Screen('Flip',w); %Changes to next screen

breakTime = round(length(parData.stimTraining)/(numBreaks+1)); %stop at some point for a break (with one break this is halfway through)
% Show Stimulus
for trial=1:length(parData.stimTraining)
    %check if we should take a break
    if ~mod(trial,breakTime) && trial~=length(parData.stimTraining)
        Screen(w, 'TextSize', 24);
        instructString = 'Take a break! Press the space bar when you are ready to start the next block';
        boundRect = Screen('TextBounds', w, instructString);
        Screen('drawtext',w,instructString, cx-boundRect(3)/2, cy-boundRect(4)/2, textColor);
        Screen('Flip',w); 
        Screen(w, 'TextSize', 36);
        
        while(1) % wait for space bar
            FlushEvents('keyDown');
            temp = GetChar;
            if (temp == ' ')
                break;
            end
        end
    end 
    
    %%get image and draw
    if (crossOn)
        Screen('DrawLines', w, bigCrossAllCoords, bigCrossLineWidthPix, bigCrossColor, [cx cy]);
    end
     betweenStimsOnset=Screen('Flip',w,blinkOnset+trainBlinkDuration/speedup-slack/2); 
    
    if (crossOn)
        Screen('DrawLines', w, bigCrossAllCoords, bigCrossLineWidthPix, bigCrossColor, [cx cy]);
    end

    Screen('DrawLines', w, fixAllCoords, fixLineWidthPix, [255 255 255], [cx cy]);
     cue1Onset = Screen('Flip',w,betweenStimsOnset+trainBetweenStimDuration/speedup-slack/2);
    
    if (crossOn)
        Screen('DrawLines', w, bigCrossAllCoords, bigCrossLineWidthPix, bigCrossColor, [cx cy]);
    end  
    Screen('DrawLines', w, fixAllCoords, fixLineWidthPix, [255 0 0], [cx cy]);
     cue2Onset = Screen('Flip',w,trainCue1Duration+cue1Onset/speedup-slack/2);

    if (crossOn)
        Screen('DrawLines', w, bigCrossAllCoords, bigCrossLineWidthPix, bigCrossColor, [cx cy]);
    end
    if useImages
        Screen('DrawTexture', w, imageTextures{trial,1},[], imageCenterRect);
    else %words
        boundRect = Screen('TextBounds', w, parData.stimTraining{trial,1});
        Screen('drawtext',w,parData.stimTraining{trial,1}, cx-boundRect(3)/2, cy-boundRect(4)/2-5, textColor);
    end
      
    jitteredCue2 = trainCue2DurationBase+trainCue2DurationRange*rand(1);
    stim1Onset = Screen('Flip',w,cue2Onset+jitteredCue2/speedup-slack/2); %show word 1

    
    if (crossOn)
        Screen('DrawLines', w, bigCrossAllCoords, bigCrossLineWidthPix, bigCrossColor, [cx cy]);
    end
     betweenStimOnset = Screen('Flip',w,stim1Onset+trainStimDuration/speedup-slack/2); %blank between words
    
    if (crossOn)
        Screen('DrawLines', w, bigCrossAllCoords, bigCrossLineWidthPix, bigCrossColor, [cx cy]);
    end
    if useImages
        Screen('DrawTexture', w, imageTextures{trial,2},[], imageCenterRect);
    else %words
        boundRect = Screen('TextBounds', w, parData.stimTraining{trial,2});
        Screen('drawtext',w,parData.stimTraining{trial,2}, cx-boundRect(3)/2, cy-boundRect(4)/2-5, textColor);
    end
    
    stim2Onset = Screen('Flip',w,betweenStimOnset+trainBetweenPairDuration/speedup-slack/2); %show word 2
    
    %blink break!
    if (crossOn)
        Screen('DrawLines', w, bigCrossAllCoords, bigCrossLineWidthPix, bigCrossColor, [cx cy]);
    end
    blinkOnset = Screen('Flip',w,stim2Onset+trainStimDuration/speedup-slack/2); %show blink break

end

instructString = 'Thank you. You have now finished training';
boundRect = Screen('TextBounds', w, instructString);
Screen('drawtext',w,instructString, cx-boundRect(3)/2, cy-boundRect(4)/5+200, textColor);
Screen('Flip',w);
WaitSecs(2)

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
