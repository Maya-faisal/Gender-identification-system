function Gender_recognizer_GUI()

     % Create a figure
     f = uifigure('Name', 'Gender recognizer', 'Position', [100, 100, 500, 500]);

    % Declare f as a persistent variable
    persistent figureHandle;
    figureHandle = f;
    
     record_button = uibutton(f, 'Text', 'Record your voice', 'Position', [70, 250, 150, 22], 'ButtonPushedFcn', @(btn,event) record());
     plot_time_button = uibutton(f, 'Text', 'Plot time domain', 'Position', [70, 200, 150, 22], 'ButtonPushedFcn', @(btn,event) plot_time(f));
     plot_freq_button = uibutton(f, 'Text', 'Plot frequency domain', 'Position', [70, 150, 150, 22], 'ButtonPushedFcn', @(btn,event) plot_freq(f));
     ZCR_button = uibutton(f, 'Text', 'Find zero cross count', 'Position', [70, 100, 150, 22], 'ButtonPushedFcn', @(btn,event) zero_count());
    
     % Create label for status messages
      status_label = uilabel(f, 'Text', '    Click your option', 'Position', [80, 20, 200, 22]);

    function record()

        % Create an audio recorder object with specified parameters
        recObj = audiorecorder(44100, 24, 1);  % Record at Fs = 44.1 kHz, 24 bits per sample

        % Prompt the user to start speaking and record for 2 seconds

        % Update the status label
        status_label.Text = 'Recording started...';

        recordblocking(recObj, 2);  

        status_label.Text = 'Audio recording completed.';

        % Retrieve the recorded audio data
        y = getaudiodata(recObj);

        % Ensure zero mean for the audio data
        y = y - mean(y);

        % Define the file name and save the recorded audio as a WAV file
        file_name = sprintf('DSP_Assignment/GUI/test.wav');
        audiowrite(file_name, y, recObj.SampleRate);

        % Add a wait time 
        pause(2);

        status_label.Text = 'choose your next option';

    end

     function plot_time(fig)

        ax = axes(fig, 'Position', [0.25, 0.4, 0.3, 0.3]);
        y = audioread('C:/Users/Dell/OneDrive/Documents/MATLAB/DSP_Assignment/GUI/test.wav');
        %y = audioread('C:/Users/Dell/OneDrive/Documents/MATLAB/DSP_Assignment/GUI/test.wav');
        plot(ax, y);
        title(ax, 'Time Domain Plot of Recorded Signal');
        xlabel(ax, 'Sample');
        ylabel(ax, 'Amplitude');

    end

    
    function plot_freq (fig)
    
        % Plot the frequency domain of the recorded signal on the provided figure
        ax = axes(fig, 'Position', [0.6, 0.4, 0.3, 0.3]); 
        [y,fs] = audioread('C:/Users/Dell/OneDrive/Documents/MATLAB/DSP_Assignment/GUI/test.wav');
        %[y, fs] = audioread('C:/Users/Dell/OneDrive/Documents/MATLAB/DSP_Assignment/GUI/test.wav');
        f = abs(fft(y));
        index_f = 1:length(f);
        index_f = index_f ./ length(f);
        index_f = index_f * fs;

        plot(ax, index_f, f);
    
         % Set x-axis limits to focus on relevant part of the spectrum (adjust as needed)
        xlim(ax, [0, 6000]);
        ylim(ax,[0,700]);

        title(ax, 'Frequency Domain Plot of Recorded Signal');
        xlabel(ax, 'Frequency (Hz)');
        ylabel(ax, 'Amplitude');
    
    end

    function zero_count()
    
    training_files_Female = dir('C:\Users\Dell\OneDrive\Documents\MATLAB\DSP_Assignment\Train\Female\*.wav');
    training_files_Male = dir('C:\Users\Dell\OneDrive\Documents\MATLAB\DSP_Assignment\Train\Male\*.wav');
    testing_files_Female = dir('C:\Users\Dell\OneDrive\Documents\MATLAB\DSP_Assignment\Test\Female\*.wav');
    testing_files_Male = dir('C:\Users\Dell\OneDrive\Documents\MATLAB\DSP_Assignment\Test\Male\*.wav');

 % ------------ Training -----------------------------
    
    % read the 'Female' training files and calculate the energy of them.
    data_Female = [];
    for i = 1:length(training_files_Female)
        file_path = strcat(training_files_Female(i).folder, '\', training_files_Female(i).name);
        [y, fs] = audioread(file_path);
    
        % divide the signal into 3 parts and calculate the ZCR for each part
        ZCR_Female1 = mean(abs(diff(sign(y(1:floor(end/3))))))./2;
        ZCR_Female2 = mean(abs(diff(sign(y(floor(end/3):floor (end*2/3))))))./2;
        ZCR_Female3 = mean(abs(diff(sign(y(floor(end*2/3):end)))))./2;
    
        % append the ZCR for the 3 parts as a row vector
        ZCR_Female = [ZCR_Female1 ZCR_Female2 ZCR_Female3];
    
        % store the raw vector in a matrix
        data_Female = [data_Female; ZCR_Female];
    
    end
    
    ZCR_Female = mean(data_Female);
    
    % read the 'Male' training files and calculate the energy of them.
    data_Male = [];
    for i = 1:length(training_files_Male)
        file_path = strcat(training_files_Male(i).folder, '\', training_files_Male(i).name);
        [y, fs] = audioread(file_path);
    
        % divide the signal into 3 parts and calculate the ZCR for each part
        ZCR_Male1 = mean(abs(diff(sign(y(1:floor(end/3))))))./2;
        ZCR_Male2 = mean(abs(diff(sign(y(floor(end/3):floor (end*2/3))))))./2;
        ZCR_Male3 = mean(abs(diff(sign(y(floor(end*2/3):end)))))./2;
    
        % append the ZCR for the 3 parts as a row vector
        ZCR_Male = [ZCR_Male1 ZCR_Male2 ZCR_Male3];
    
        % store the raw vector in a matrix
        data_Male = [data_Male; ZCR_Male];
    
    end
    
    ZCR_Male = mean(data_Male);
    

 % ------------ Evaluation -----------------------------


    % Initialize counters for True Positives, True Negatives, False Positives, and False Negatives
    % to calculate the accuracy
    TP = 0;
    TN = 0;
    FP = 0;
    FN = 0;
    
    % Process Female testing files
    for i = 1:length(testing_files_Female)
        file_path = strcat(testing_files_Female(i).folder, '\', testing_files_Female(i).name);
        [y, fs] = audioread(file_path);
    
        y = y - mean(y);
    
        % **Apply filtering to reduce noise**
        y = bandpass(y, [300, 3400], fs);  % Filter within typical human voice frequency range
    
        % Divide the signal into 3 parts and calculate the ZCR for each part
        ZCR_Female1 = mean(abs(diff(sign(y(1:floor(end/3))))))./2;
        ZCR_Female2 = mean(abs(diff(sign(y(floor(end/3):floor(end*2/3))))))./2;
        ZCR_Female3 = mean(abs(diff(sign(y(floor(end*2/3):end)))))./2;
    
 
        % Append all features as a row vector
        features_y = [ZCR_Female1 ZCR_Female2 ZCR_Female3];
   
        %make the decision based on euclidean distance
        if(pdist([features_y;ZCR_Female],'euclidean') < pdist([features_y;ZCR_Male],'euclidean'))
            TP = TP + 1; % True Positive
        else
            FN = FN + 1; % False Negative
        end
    end

    % Process Male testing files
    for i = 1:length(testing_files_Male)
        file_path = strcat(testing_files_Male(i).folder, '\', testing_files_Male(i).name);
        [y, fs] = audioread(file_path);
    
        y = y - mean(y);
    
        % **Apply filtering to reduce noise**
        y = bandpass(y, [300, 3400], fs);  % Filter within typical human voice frequency range
    
        % Divide the signal into 3 parts and calculate the ZCR for each part
        ZCR_Male1 = mean(abs(diff(sign(y(1:floor(end/3))))))./2;
        ZCR_Male2 = mean(abs(diff(sign(y(floor(end/3):floor(end*2/3))))))./2;
        ZCR_Male3 = mean(abs(diff(sign(y(floor(end*2/3):end)))))./2;
    
        % Append all features as a row vector
        features_y = [ZCR_Male1 ZCR_Male2 ZCR_Male3];

       %make the decision based on euclidean distance
        if(pdist([features_y;ZCR_Female],'euclidean') < pdist([features_y;ZCR_Male],'euclidean'))
            FP = FP + 1; % False Positive
        else
            TN = TN + 1; % True Negative
        end
    end

    
    % Calculate accuracy
    accuracy = (TP + TN) / (TP + TN + FP + FN);

    % Create label for status messages
    string_label = uilabel(figureHandle, 'Text', '  ', 'Position', [700, 200, 200, 22]);
    string_label.Text = sprintf('Result Accuracy: %.2f%%\n', accuracy * 100);
    string_label.FontSize = 15;


    [y, ~] = audioread('C:/Users/Dell/OneDrive/Documents/MATLAB/DSP_Assignment/GUI/test.wav');
    
    % divide the signal into 3 parts and calculate the ZCR for each part
    ZCR1 = mean(abs(diff(sign(y(1:floor(end/3))))))./2;
    ZCR2 = mean(abs(diff(sign(y(floor(end/3):floor(end*2/3))))))./2;
    ZCR3 = mean(abs(diff(sign(y(floor(end*2/3):end)))))./2;
    
    % append the ZCR for the 3 parts as a row vector
    y_ZCR = [ZCR1 ZCR2 ZCR3];
    
    % Make sure ZCR_Female and ZCR_Male have the same length
    min_length = min(length(ZCR_Female), length(ZCR_Male));
    ZCR_Female = ZCR_Female(1:min_length);
    ZCR_Male = ZCR_Male(1:min_length);
    
     % Make the decision based on Euclidean distance
     distance_Female = pdist([y_ZCR; ZCR_Female], 'euclidean');
     distance_Male = pdist([y_ZCR; ZCR_Male], 'euclidean');
    
     % Display the result using msgbox only once
     if distance_Female < distance_Male
         msgbox(sprintf('Classified as Female\n your Zero cross count = [%d, %d, %d] \n Female Zero cross count = [%d, %d, %d] \n Distance = %d',y_ZCR,ZCR_Female,distance_Female), 'Result', 'modal');
     else
       msgbox(sprintf('Classified as Male\n your Zero cross count = [%d, %d, %d] \n Male Zero cross count = [%d, %d, %d] \n Distance = %d',y_ZCR,ZCR_Male,distance_Male), 'Result', 'modal')
     end
    
    end

end

