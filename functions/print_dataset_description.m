function print_dataset_description(tld,patient_ids,signals,all_unique_patid,hb_signals,dataset_label)
    % Get the index of only one patient ID
    [~,idx] = unique(patient_ids);
    a = unique(patient_ids,'stable');

    BIRTH_Gender = tld.BIRTH_Gender(idx);
    PMA = tld.PMA(idx) /7;
    PNA_evt_start = tld.evt_start_pna_days/7;
    PMA_evt_start = tld.evt_start_pma_days/7;

    BIRTH_weight = tld.BIRTH_weight(idx);
    respirators = tld.TESTOD_CurrentVentilation;
    
    a = unique(patient_ids,'stable');
    count_transfusions=cell2mat(cellfun(@(x) sum(ismember(patient_ids, x)),a,'un',0));

    fprintf('Total, [n-evts]=%d, [n-patients]=%d\n', size(signals,2), size(all_unique_patid,1));
    print_demographics(BIRTH_weight, BIRTH_Gender, PMA);
    print_evt_demographics(PMA_evt_start, PNA_evt_start)
    print_respirator(respirators)
    
    incr_hb = hb_signals(2,:)-hb_signals(1,:);
    incr_hb_str=sprintf('Increment Hb: %.1f (%.1f) (Missing: %d/%d)', mean(hb_signals(2,:) - hb_signals(1,:),'omitnan'), std(hb_signals(2,:)-hb_signals(1,:),'omitnan'),sum(isnan(incr_hb)),size(hb_signals,2) );
    pre_hb_str=sprintf('Pre Hb: %.1f (%.1f) (Missing: %d/%d)', mean(hb_signals(1,:),'omitnan'), std(hb_signals(1,:),'omitnan'),sum(isnan(hb_signals(1,:))),size(hb_signals,2));
    post_hb_str=sprintf('Post Hb: %.1f (%.1f)  (Missing: %d/%d)', mean(hb_signals(2,:),'omitnan'), std(hb_signals(2,:),'omitnan'),sum(isnan(hb_signals(2,:))),size(hb_signals,2));
    
    vol = tld.transfusion_volume;
    rates = tld.transfusion_rate;
    
    n = size(vol,2);
    
    volumes_str = data_description(vol, 'Volumes (ml)'); 
    rates_str = data_description(rates, 'Rates');
    
    volumes_per_kilo_str = data_description(vol./tld.TESTOD_MostRecentWeight, 'Dose (ml/kg)'); 
    rates_per_kg_str = data_description(tld.transfusion_rate./tld.TESTOD_MostRecentWeight, 'Rates (/kg)');
  
    fig=figure; plot(vol./tld.TESTOD_MostRecentWeight, tld.transfusion_rate./tld.TESTOD_MostRecentWeight,'.','MarkerSize',10)
    xlabel('Dose (ml/kg)'); ylabel('Rates (ml/h/kg)')
    exportgraphics(fig, sprintf('../results/%s_rates_vs_dose.jpg',dataset_label), 'BackgroundColor', 'none','Resolution',300);
    
    transfusion_counts_str = data_description(count_transfusions', '[n-evts] per patients');
    
    fprintf('%s\n%s\n%s\n%s\n%s\n%s\n%s\n', pre_hb_str, post_hb_str, incr_hb_str,volumes_per_kilo_str,rates_str,rates_per_kg_str,transfusion_counts_str);
    
end