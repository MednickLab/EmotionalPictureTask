# Generic Memory Task
Generic MATLAB/Psychtoolbox code to run a variety of memory tasks. Can be used to create Word Pair Associates (included) task, Emotional Picture Task (included), and many more. Handles images, words and word pairs as stimulus. Handles recognition and recall (words only) memory tests.
The general structure consists of:

- General "run" code that controls which session runs etc (e.g. runWPA)
- Code to check for overwrites and if necessary data exists (e.g. checkFiles)
- Code to run a "Train"/"Encoding" session, where stim are presented to a subject one at a time (or pairs) (e.g. train_sequentual)
- Code to run a "Test"/"Recognition" session/s, where previously presented stim are shown again and subjects are asked to make a memory judgement (test_recog)
- Code to calculate stats (e.g. runStats_WPA)
- A settings file that controls all task parameters (timing, which lists are run, how many image to run, text to display etc)

# Features:
 - pop up input dialogs to enter subject id, session id, or other parameters
 - a script to check if data already exists, and warn if anything will be overwritten
 - The ability to train to a threshold accuracy before ending the training session
 - Crosshairs for subjects to focus on
 - Auto saving of files if some error occurs
 - Stats automatically calculated (accuracy, dprime, etc) and saved to CSV file
 - Modifiable word, image lists
 - For pairs of images/words, the ability to present side by side and sequentially
 - Modifiable stim timing settings
 - Stem completion for words
 - Recall and recognition based test sessions
 - Feedback during training or test
 - Automatically pull correct stimulus set for subject from a counterbalance file
 - pressing "s" key at instructions starts normal, pressing "=" key will speed through everything (useful for debug)
 
 An example of the settings file is shown below, each variable settings file has a description in the second column:
 
 | VARIABLE                 | NOTES                                                                                          | Example Value                                        |
|--------------------------|------------------------------------------------------------------------------------------------|------------------------------------------------------|
| useImages                | Wether or not this task uses images. Should be 0                                               | 0                                                    |
| numPrimacy               | Number of words used in primacy. This is set in the wordlist file so is   set as NA (-1) here  | -1                                                   |
| numRecency               | Number of words used in recency. This is set in the wordlist file so is   set as NA (-1) here  | -1                                                   |
| numFamilStimPerTest      | Number of words used in training. This is set in the wordlist file so is   set as NA (-1) here | -1                                                   |
| numTests                 | Number of tests                                                                                | 2                                                    |
| numRepetitions           | number of times the stimulus will repleate in training                                         | 1                                                    |
| crossOn                  | 1=giant low contrast cross on screen 0=no cross                                                | 1                                                    |
| trainStimDuration        | how long the training stimulus is displayed for                                                | 1                                                    |
| trainBetweenPairDuration | the time between each stim in a pair when running sequenctual training                         | 0.4                                                  |
| trainBetweenStimDuration | the time between stimulus in training                                                          | 2                                                    |
| trainCue1Duration        | Time for the white fixaction cross                                                             | 2                                                    |
| trainCue2DurationBase    | min time for the red fixation cross                                                            | 0.5                                                  |
| trainCue2DurationRange   | range of the jittered red cross (from base to base plus range)                                 | 1                                                    |
| trainBlinkDuration       | The time at the end of a cycle for a blink                                                     | 0                                                    |
| numBreaks                | The number of breaks in the training session                                                   | 3                                                    |
| testStimDuration         | how long the training stimulus is displayed for                                                | 1                                                    |
| testBetweenStimDuration  | the time between each stim in a pair when running sequenctual training                         | 0.4                                                  |
| testCue1Duration         | Time for the white fixaction cross                                                             | 2                                                    |
| testCue2DurationBase     | base time for the red fixation cross the total time is this + the range   of jitter            | 0.5                                                  |
| testCue2DurationRange    | range of the jittered red cross (from base to base plus range)                                 | 1                                                    |
| testResponseDuration     | the time between stimulus in testing                                                           | 5                                                    |
| testBlinkDuration        | The time at the end of a cycle for a blink (time between response and   first cue)             | 0.2                                                  |
| trainBlurb               | The text displayed on screen before training                                                   | You will be shown word pairs on the screen, etc, etc |
| test1InitBlurb           | The text displayed on screen before testing 1                                                  | You will now be tested on the word pairs, etc, etc   |
| test2InitBlurb           | The text displayed on screen before testing 2                                                  | You will now be tested on the word pairs, etc, etc   |
| acceptableTestAns        | acceptable anwsers at test                                                                     | 1                                                    |
| intactAns                | posible answers when subject thinks its intact                                                 | 1                                                    |
| novelAns                 | possible novel ans                                                                             | 4                                                    |
| rearangedAns             | psibile answers when subject think its rearanged                                               | 7                                                    |

 Modifications of the basic settings files should be accessible for anyone, regardless of coding background. Modifying other aspects of the code or making your own task from existing parts will require some MATLAB knowledge.
 
 # Pre-Packaged session examples
### Training
```train_pairsSequential``` Displays pairs of words or images one after another, with no response
```train_singleWithResponse``` Displays a single word or image, and asked for a response

### Testing
```test_recall``` Test cued recall (i.e. given one word, type its pair), or cued stem recall (given one word, and the first letter of the pair, recall the pair)
```test_recall2Threshold``` Forces user to get some percentage accuracy during recall task before moving on. Words will continue to be displayed until accuracy above threshold. Useful to run right after training with all words to make sure encoding strenght is high enough.
```test_recog``` Displays images, image pairs, words or word pairs and asks for a response.
```test_recogSequential``` Displays word or image pairs, one after another, and asks for a response.

 # Pre-Packaged Full Examples
 ## Word Pair Associates (runWPA)
 - Encoding + two test sessions
 - Stim are words pairs.
 - During training, word pairs are presented. No response is asked for
 - During testing, intact pairs (same as in encoding), rearranged pairs (old words, but new pairing), new pairs (both words new)
   are presented and subject is asked to make a recognition decision
 - Was designed for ERPs, so focus cross is pail and constant, and screen is black
 - Participants can take a break every x word pairs
 - Test sessions are recognition (old/new) and w. confidence
 - Word pairs are presented sequentially + a blink break between word pairs
 - Stats are calculated for each sub (dprime - although this is a little weird because there are 3 options - intact, rearranged, new)

## EPT (runEPT)
 - Encoding + two test sessions
 - During training images of 3 valences (pos/neg/neutral) are presented sequentially, and a response asked (you chose the question)
 - At test, old images from training and new images are shown, and the subject is asked to perform a recognition decision
 - Stim are images of 3 valences (neg/pos/neu)
 - Test sessions are recognition (old/new) and w. confidence
 - Stats are calculated for each sub (dprime) and separately for each subject


