function [signals, colors,signal_increase,signal_decrease,var_labels,subjectid,studyid,sig_quality,tld]=plot_vital_signs(files, t_limits, t_window, t_overlap, t_baseline, sig_check, dataset_label, std_threshold)
% - plot_vital_signs(files, t_window, t_overlap, sig_check, dataset_label,
% std_threshold) -- plots the vital signs responses after time-locking to 
% transfusion events.
% 
% 
% Input
% - files           - File paths to be analysed. Paths should be defined as
%                     directory names in cell structure.
% - t_limits        - Time limits in hours defined as double variable
% - t_window        - Window size in hours defined as double variable.
% - t_overlap       - Overlap between consecutive windows in hours defined 
%                     as double.
% - t_baseline      - Time limits in hours used for baseline correction
%                     (i.e., mean subtraction) defined as double variable.
% - sig_check       - Boolean specifying if vital signs time series should
%                     be visualise and checked.
% - dataset_label   - 'Berlin', 'Oxford', or 'Stockholm'. Will be used to
%                     reformat data structure if necessary.
% - std_threhsold   - Threshold used to define (non-)responders;
%                     it should be exceeded post-transfusion start to be
%                     classified as responder.
%
%
% Example usage
% - define_subjects_Oxford (example script for data structure).
% - t_window = 1; % hours
% - t_overlap = 0.5; % hours
% - t_limits = [-6, 12]; % hours
% - t_baseline = [-6, 0]; % hours
% - check_sig = true;
% - dataset_label = 'Oxford';
% - std_threshold = 1.5;
% - plot_vital_signs(files, t_limits, t_window, t_overlap, t_baseline, ...
%       check_sig, dataset_label, std_threshold)
%
%
% See also MOVING_AVERAGE, TIME_LOCK_DATA, CHECK_SIGNALS, FIND_RESPONDERS
% ________________________________________________________________________
%
% This file is released under the terms of the GNU General Public License,
% version 3. See http://www.gnu.org/licenses/gpl.html
%
%                                           (c) Coen Zandvoort, Caroline Hartley 2024
% ________________________________________________________________________

% check input and set defaults if necessary
if nargin < 2, t_limits = [-6, 12]; end
if nargin < 3, t_window = 1; end
if nargin < 4, t_overlap = 0.5; end
if nargin < 5, sig_check = true; end
if nargin < 6, dataset_label = 'Oxford'; end
if nargin < 7, std_threshold = 1.5; end


% check the availability of the functions folder
preprocessed_data_folder = '../preprocessed';
if exist(strcat(preprocessed_data_folder,'/rawtransfusiondata.excelmat'))
    load(strcat(preprocessed_data_folder,'/rawtransfusiondata.mat'))
else
    % pre-allocate some struct and fields
    tld = struct;
    tld.counter = 1;
    tld_nocorrection = struct;
    tld_nocorrection.counter=1;
    tld.BIRTH_Gender = {};
    tld.PMA = [];
    tld.BIRTH_weight = [];
    tld.hb_pre = [];
    tld.hb_post = [];
    tld.fiO2_pre = [];
    tld.fiO2_post = [];
    tld.transfusion_volume = [];
    tld.transfusion_rate = [];

    tld.evt_start_pma_days = [];
    tld.evt_start_pna_days = [];

    tld.TESTOD_CurrentVentilation={};
    tld.TESTOD_MostRecentWeight=[];
    
    toremove=[]; subjectid=[]; studyid=[];
    
    var_labels = {'hr_mean', 'sats_mean', 'rr_mean', 'hr_std', 'sats_std', 'rr_std'};
    
    if strcmp(dataset_label, 'Stockholm')
        patient_ids= cell(size(files, 1),1);
    end
    
    for f = 1 : size(files, 1)
        
        % load vital signs and inter-breath interval data
        %fprintf('reading:\t"%s"\n', files{f, 1})
        vs = load(files{f, 1});

        if size(files, 2) > 1
            if ~isempty(files{f, 2})
                % load inter-breath intervals
                vs.ibi = load(files{f, 2});
            end
        end
        
        % Berlin and Stockholm data structure should be reformatted to match 
        % the Oxford data
        vs.dataset_label = dataset_label;
        
        if strcmp(dataset_label, 'Stockholm')
            [vs,studyid,patient_ids{f}] = standardize_stockholm(vs,studyid,files,f);
        end
        
        if strcmp(dataset_label, 'Berlin')
            % Here, we may have to add some extra lines of code to make the
            % Berlin and Stockholm data similar to the Oxford data. 
            vs.time_events_vital_signs = vs.time_events_vital_signs;
            vs.events_vital_signs = {'rbctransfusion_start','rbctransfusion_stop'};
            vs.HR = vs.HR;
            vs.sats = vs.sats;
            vs.RR = vs.RR;
            vs.BP = vs.BP;
            vs.fiO2 = vs.fiO2;
        end
    
        % find transfusion starts
            % find transfusion starts - will skip data set if it can't find
        % transfusion start
        if ~isfield(vs, 'events_vital_signs'); disp('no data'); toremove=[toremove;f]; continue; end
        
        if ~any(find(contains(vs.events_vital_signs, 'transfusion') & ...
            contains(vs.events_vital_signs, 'start'))); disp('no transfusion marker'); toremove=[toremove;f]; continue; end
        
        if strcmp(dataset_label, 'Berlin')
            fs=0.0011;
        end
    
        if strcmp(dataset_label, 'Oxford') || strcmp(dataset_label, 'Stockholm')
            fs = 0.9766;
        end
    
        % time-lock data
        tld = time_lock_data(vs, tld, t_limits, t_baseline, fs);
        %  tld_nocorrection = time_lock_data_nocorrection(vs, tld_nocorrection, t_limits);
        
        if strcmp(dataset_label, 'Oxford')
            n = length(find(contains(vs.events_vital_signs, 'transfusion') & contains(vs.events_vital_signs, 'start')));
            for i = 1 : n
                subjectid = [subjectid;files{f}(31:37)];
                studyid = [studyid;files{f}(39:47)];
            end
        end
    
    end
   
    % identify bradycardia, tachycardia, desats
    % time_events=identify_desatbradytachy(tld_nocorrection);
    
    % get moving average
    tld = moving_average(tld, t_window, t_overlap);
    
    % check vital signs signals visually (note that if sig_check is set to
    % false all data will be included). 
    if isfield(tld, 'ibi_locked'); var_labels = [var_labels, {'resp_rate', 'ibi_std', 'apnoea_rate_5_sec', 'apnoea_rate_10_sec'}]; end
    %if isfield(tld, 'fiO2_mean'); var_labels = [var_labels, {'fiO2_mean','Hb_mean', 'fiO2_std','Hb_std'}]; end
    
    sig_quality = true(numel(var_labels), tld.counter - 1);
    
    if sig_check
    
        % extract signal quality (for now, the code will check if the
        % sig_quality.mat file is available. If this is the case, the user
        % doesn't get the option to re do the signal selection. Delete the file
        % sig_quality.mat if you would like to re do this selection). 
        if ~exist(sprintf('%s/sig_quality_%s.mat', preprocessed_data_folder, dataset_label), 'file')
    
            for v = 1 : numel(var_labels)
                x = tld.(sprintf('%s', var_labels{v}));
                time = tld.t_average;
                events = tld.t_stop;
    
                fprintf('\nassessing "%s"\n', var_labels{v})
                %sig_quality(v, :) = check_signals(x, time, events);
                if ~strcmp(dataset_label, 'Stockholm')
                    sig_quality(v, :) = check_signals(x, time, events);
                else
                    sig_quality(v, :) = sum(isnan(x),1)==0;
                end
            end
    
            % save output
            save(sprintf('%s/sig_quality_%s.mat',preprocessed_data_folder, dataset_label), 'sig_quality')
    
        end
    
    end
    close
    load(sprintf('%s/sig_quality_%s.mat',preprocessed_data_folder, dataset_label), 'sig_quality')
    
    alpha = 0.2;
    timeline = tld.t_average;
    %clear std_threshold
    save(strcat(preprocessed_data_folder,'/rawtransfusiondata'))
end

% plot mean response over all transfusions
fig = figure;
po = get(gcf, 'position');
set(gcf, 'position', [po(1:2), 1600, 1000], 'name', 'timelocked_responses');


y_names = {'Mean HR [bpm]', 'Mean Sats [%]', 'Mean RR [breaths/min]', 'Std HR [bpm]', 'Std Sats [%]', 'Std RR [breaths/min]'};
if isfield(tld, 'ibi_locked'); y_names = [y_names, {'Resp rate [breaths/min]', 'Std IBI [sec]', 'Apnoea rate 5 sec [times/hour]', 'Apnoea rate 10 sec [times/hour]'}]; end
%if isfield(tld, 'fiO2_mean'); y_names = [y_names, {'Mean fiO2 (%)','Mean Hb', 'Std fiO2 (%)','Std Hb'}]; end

for v = 1 : numel(var_labels)

    % mean subtract the moving average to mean of t_baseline
    idx_baseline = tld.t_average > t_baseline(1) & tld.t_average < t_baseline(2);
    tld.(var_labels{v}) = tld.(var_labels{v}) - mean(tld.(var_labels{v})(idx_baseline, :), 'omitnan');
    

    % plot mean and standard deviations
    subplot(2, numel(y_names) / 2, v);

    idx_include = find(sig_quality(v, :));

    m = mean(tld.(var_labels{v})(:, idx_include), 2, 'omitnan');
    s = std(tld.(var_labels{v})(:, idx_include), [], 2, 'omitnan');
    plot(tld.t_average, m, 'Color', [0.5, 0.5, 0.5], 'LineWidth', 2);
    hold on;
    patch([tld.t_average; tld.t_average(end : -1 : 1)], [m + s; m(end : -1 : 1) - s(end : -1 : 1)], [0.5, 0.5, 0.5], 'FaceAlpha', 0.5, 'EdgeColor', [1, 1, 1]);
    plot([0, 0], [min(m - s), max(m + s)], 'k--', 'LineWidth', 2);
    plot(t_limits, [0, 0], 'k--', 'LineWidth', 1);
    plot([mean(tld.t_stop(idx_include), 'omitnan'), mean(tld.t_stop(idx_include), 'omitnan')], [min(m - s), max(m + s)], 'k--', 'LineWidth', 2);

    title(sprintf('%s', var_labels{v}), 'Interpreter', 'None');
    xlabel('Time [hours]');
    ylabel(y_names{v});
    xlim([tld.t_average([1, end])])
    ylim([min(m - s), max(m + s)])
end
orient(fig, 'landscape')
exportgraphics(fig, sprintf('../results/timelocked_data_all_patients_%s.jpg',dataset_label), 'BackgroundColor', 'none','Resolution',300);
print(sprintf('../results/timelocked_data_all_patients_%s.pdf',dataset_label), '-dpdf', '-bestfit')
%print(sprintf('../results/timelocked_data_all_patients_%s_2.jpg',dataset_label), '-djpg', '-bestfit')

%all_markers = {'s','*','o','p'};
rates_per_kilo = tld.transfusion_rate./tld.TESTOD_MostRecentWeight;
vol_per_kilo = tld.transfusion_volume./tld.TESTOD_MostRecentWeight;

tld.good_rate_volume = (rates_per_kilo >= 3) & vol_per_kilo >= 8;

sig_quality(:, ~tld.good_rate_volume) = 0;

tld.sig_quality = sig_quality;

%cluster analysis
cluster_analysis = false;
if cluster_analysis
    pre = find(tld.t_average<0);
    post = find(tld.t_average>0);
    
    if strcmp(dataset_label, 'Stockholm')
        idx_include_hr = sig_quality(1,:);
        idx_include_sats = sig_quality(2,:);
        idx_include_rr = sig_quality(3,:);
    else
        idx_include_hr = idx_include;
        idx_include_sats = idx_include;
        idx_include_rr = idx_include;
    end


    dataPrehrmean=tld.hr_mean(pre,idx_include_hr);
    dataPosthrmean=tld.hr_mean(post,idx_include_hr);
    disp('cluster analysis HR mean') 
    montecarlo_fornewdata_differentsizes(dataPrehrmean', dataPosthrmean', 1/t_overlap, t_limits(1)+1, t_limits(2));
    
    dataPrehrsd=tld.hr_std(pre,idx_include_hr);
    dataPosthrsd=tld.hr_std(post,idx_include_hr);
    disp('cluster analysis HR SD') 
    montecarlo_fornewdata_differentsizes(dataPrehrsd', dataPosthrsd', 1/t_overlap, t_limits(1)+1, t_limits(2));
    
    dataPresatsmean=tld.sats_mean(pre,idx_include_sats);
    dataPostsatsmean=tld.sats_mean(post,idx_include_sats);
    disp('cluster analysis Sats mean') 
    montecarlo_fornewdata_differentsizes(dataPresatsmean', dataPostsatsmean', 1/t_overlap, t_limits(1)+1, t_limits(2));
    
    dataPresatssd=tld.sats_std(pre,idx_include_sats);
    dataPostsatssd=tld.sats_std(post,idx_include_sats);
    disp('cluster analysis Sats SD') 
    montecarlo_fornewdata_differentsizes(dataPresatssd', dataPostsatssd', 1/t_overlap, t_limits(1)+1, t_limits(2));
    
    dataPrerrmean=tld.rr_mean(pre,idx_include_rr);
    dataPostrrmean=tld.rr_mean(post,idx_include_rr);
    disp('cluster analysis RR mean')
    montecarlo_fornewdata_differentsizes(dataPrerrmean', dataPostrrmean', 1/t_overlap, t_limits(1)+1, t_limits(2));
    
    dataPrerrsd=tld.rr_std(pre,idx_include_rr);
    dataPostrrsd=tld.rr_std(post,idx_include_rr);
    disp('cluster analysis RR SD')
    montecarlo_fornewdata_differentsizes(dataPrerrsd', dataPostrrsd', 1/t_overlap, t_limits(1)+1, t_limits(2));
end

% find responders
%find_responders(tld, std_threshold)


if 1
    [signals, colors, all_colors,signal_increase,signal_decrease,tld.pre_post_hb,all_colors_names] = find_responders(tld, std_threshold, 6, 0);
    
    %find subject labels for Oxford data
    if strcmp(dataset_label, 'Oxford')
        all_unique_patid = unique(subjectid);
        patient_ids_integer = str2num(subjectid(:,end-1:end));
    end
    
    
    if strcmp(dataset_label, 'Stockholm')
        % Convert the list of hex IDs to integer ids
        
        all_unique_patid = unique(patient_ids);
        subjectid = patient_ids;
        patient_ids_integer = zeros(size(patient_ids,1),1);
        for ipat = 1:size(all_unique_patid,1)
            patient_ids_integer(find(contains(patient_ids, all_unique_patid{ipat}))) = ipat;
        end
        
        print_dataset_description(tld, patient_ids, signals, dataset_label)
    end
    
    % Average lines per response patient groups
    for isig =1:numel(var_labels)
        fig = figure;
        
        % Good quality recordings
        idx_good_quality = sig_quality(isig, :) == 1;
        if strcmp(dataset_label, 'Oxford') || strcmp(dataset_label, 'Stockholm')
            % Count unique patients with good quality recordings of the VS
            npatsig = size(unique(patient_ids_integer(idx_good_quality)), 1);
            idx_full_hb = filter_full_hb(tld.pre_post_hb);
            
            full_hb = tld.pre_post_hb(:, idx_good_quality & idx_full_hb);
            %full_hb = hb(:, sum(isnan(hb),1)==0);
            
            patid_included = patient_ids_integer(idx_good_quality);
            [~, idx] = unique(patid_included);
            unique_patid_sig_hb = patid_included(idx);
    
            fprintf('\n\nVariable=%s, n-patients=%d, n-evt=%d, n-fullHB=%d\n', ...
                    var_labels{isig}, npatsig, sum(idx_good_quality), size(full_hb,2));
    
            print_demographics(tld.BIRTH_weight(unique_patid_sig_hb), tld.BIRTH_Gender(unique_patid_sig_hb), tld.PMA(unique_patid_sig_hb))
    
        end
        % for each types of responses, excluding the "green" for readability (both
        % increase and decrease) 
        for icolor = 1:size(all_colors,2)
            if ~strcmp(all_colors{icolor},'green')
                idx_sigcolor = (idx_good_quality) & (colors(isig,:)==icolor);
                %hb = tld.pre_post_hb(:, idx_sigcolor);
                %full_hb = hb(:, filter_full_hb(hb)); %hb(:, sum(isnan(hb),1)==0);
                
                displayname = '# Transfusions=%d\n# Patients=%d\n';
    
                if strcmp(dataset_label, 'Oxford') || strcmp(dataset_label, 'Stockholm')
                    patid_included = patient_ids_integer(idx_sigcolor);
                    [~, idx] = unique(patid_included);
                    unique_patid_sigcolor = patid_included(idx);
                    
                    npatsigcolor = size(idx,1);
    
                    displayname = sprintf(displayname, sum(idx_sigcolor), npatsigcolor);
                end
                fprintf('\tcolor=%s\n%s\n', all_colors_names{icolor}, displayname);
                
                print_demographics(tld.BIRTH_weight(unique_patid_sigcolor),tld.BIRTH_Gender(unique_patid_sigcolor),tld.PMA(unique_patid_sigcolor))
                
                data_sigcolor = squeeze(signals(isig, idx_sigcolor,:));
                if size(data_sigcolor, 2)==1 %this happens if only 1 transfusion in group
                    data_sigcolor=data_sigcolor';
                    m = mean(data_sigcolor, 1, 'omitnan')';
                    s = 0;
                else
                    m = mean(data_sigcolor, 1, 'omitnan')';
                    s = std(data_sigcolor, 1, 'omitnan')';
                end
                plot(timeline, m, 'Color', all_colors{icolor}, 'LineWidth', 2, 'DisplayName', displayname);
                %%%%plot(timeline, m, 'Color', [0.5, 0.5, 0.5], 'LineWidth', 2,'DisplayName',displayname);
                hold on;
                patch([timeline; timeline(end : -1 : 1)], ...
                    [m + s; m(end : -1 : 1) - s(end : -1 : 1)], all_colors{icolor}, ...
                    'FaceAlpha', alpha, 'EdgeColor', all_colors{icolor},'EdgeAlpha',alpha,'HandleVisibility','off');
                
                plot([0, 0], [min(m - s), max(m + s)], 'k--', 'LineWidth', 2,'HandleVisibility','off');
                
                hold on
                %%% plot([mean(tld.t_stop(idx_include), 'omitnan'), mean(tld.t_stop(idx_include), 'omitnan')], [min(m - s), max(m + s)], 'k--', 'LineWidth', 2);
            end
        end
        legend('NumColumns', 3, 'Location', 'northoutside');
    
    %     idx_include = find(sig_quality(isig, :));
    %     m = mean(tld.(var_labels{v})(:, idx_include), 2, 'omitnan');
    %     s = std(tld.(var_labels{v})(:, idx_include), [], 2, 'omitnan');
    %     for ipat = 1:size(signals,3)
    %        thecolor=colors(isig,ipat);
    %        % Signal quality was good and not classified as non-responder
    %        if (tld.sig_quality(isig, ipat) == 1) && all(thecolor ~= [1, 0.41, 0.38])
    %            plot(squeeze(timelines(isig,ipat,:)), ...
    %                 squeeze(signals(isig,ipat,:)), ...
    %                 color=thecolor);
    %            hold on
    %        end
    %     end
    %     % Background color
    %     set(gca,'Color',[1 1 1])
    
        % Looking nice
        set(findall(0, 'type', 'axes'), 'FontName', 'Times', 'Fontsize', 16, 'TickDir', 'out', 'box', 'off', 'linewidth', 2, 'ticklength', [0.01, 0.01])
        orient(fig, 'landscape')
        
        xlabel('Time [hours]')
        ylabel(y_names{isig});
        xlim([timeline(1),timeline(end)])
        set(gcf,'Units','normalized','OuterPosition',[0 0 0.25 0.3]);

        % Save
        exportgraphics(fig, sprintf('../results/%s_all_patients_%s.jpg', sprintf(var_labels{isig}), dataset_label), 'BackgroundColor', 'None', 'Resolution', 300);
        %print(sprintf('../results/%s_all_patients_%s.jpg',sprintf(var_labels{isig}),dataset_label), '-djpg','-bestfit');
    
    end
    
    %plot piecharts for type of responses
    fig = figure;
    for isig =1:numel(var_labels)
        both=length(find(colors(isig,:)==1));
        increase=length(find(colors(isig,:)==2));
        decrease=length(find(colors(isig,:)==3));
        nochange=length(find(colors(isig,:)==4));
        tot_num=length(find(sig_quality(isig)));
    
        subplot(ceil(numel(var_labels)/3),3,isig)
        
        piechart([increase,decrease,nochange],["increase","decrease","no change"],'LegendVisible', 'off', 'FontSize', 14)
        title(y_names{isig});

    end
    set(findall(0, 'type', 'axes'), 'FontName', 'Times', 'Fontsize', 24, 'TickDir', 'out', 'box', 'off', 'linewidth', 2, 'ticklength', [0.01, 0.01])

    set(gcf,'Units','normalized','OuterPosition',[0 0 0.5 0.3]);


    exportgraphics(gcf, sprintf('../results/piechart_all_patients_%s.jpg',dataset_label), 'BackgroundColor', 'none','Resolution',300);

    % save
    print(sprintf('../results/piechart_all_patients_%s.pdf',dataset_label),'-dpdf','-bestfit')
    
end
end

function idx_full_hb = filter_full_hb(data)
% Data of size (2,N), returns the indices of events with complete Hb data
    
    %idx_full_hb = sum(isnan(data),1)==0;

    % Ignore events without endHb data
    idx_full_hb = true(1,size(data,2));% sum(isnan(data),1)==0;
end
% _ EOF____________________________________________________________________
