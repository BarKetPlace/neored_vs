function tld3 = concatenate_tld(tld1, tld2)
    tld3 = struct;
    
    tld3.sig_quality = [tld1.sig_quality, tld2.sig_quality];
    tld3.pre_post_hb = [tld1.pre_post_hb, tld2.pre_post_hb];

    tld3.evt_start_pna_days = [tld1.evt_start_pna_days,tld2.evt_start_pna_days];
    tld3.evt_start_pma_days = [tld1.evt_start_pma_days,tld2.evt_start_pma_days];
    tld3.transfusion_rate = [tld1.transfusion_rate, tld2.transfusion_rate];
    tld3.transfusion_volume = [tld1.transfusion_volume, tld2.transfusion_volume];
    tld3.fiO2_post = [tld1.fiO2_post, tld2.fiO2_post];
    tld3.fiO2_pre = [tld1.fiO2_pre, tld2.fiO2_pre];
    
    tld3.hb_post = [tld1.hb_post, tld2.hb_post];
    tld3.hb_pre = [tld1.hb_pre, tld2.hb_pre];
    tld3.hb_pre = [tld1.hb_pre, tld2.hb_pre];

    tld3.BIRTH_weight = [tld1.BIRTH_weight, tld2.BIRTH_weight];
    tld3.TESTOD_CurrentVentilation = [tld1.TESTOD_CurrentVentilation, tld2.TESTOD_CurrentVentilation];

    tld3.TESTOD_MostRecentWeight = [tld1.TESTOD_MostRecentWeight, tld2.TESTOD_MostRecentWeight];
    tld3.PMA = [tld1.PMA, tld2.PMA];
    tld3.BIRTH_Gender = [tld1.BIRTH_Gender, tld2.BIRTH_Gender];

    tld3.hr_mean = [tld1.hr_mean, tld2.hr_mean];
    tld3.hr_std = [tld1.hr_std, tld2.hr_std];
    
    tld3.sats_mean = [tld1.sats_mean, tld2.sats_mean];
    tld3.sats_std = [tld1.sats_std, tld2.sats_std];
    
    tld3.rr_mean = [tld1.rr_mean, tld2.rr_mean];
    tld3.rr_std = [tld1.rr_std, tld2.rr_std];
    tld3.good_rate_volume = [tld1.good_rate_volume, tld2.good_rate_volume];
    assert(all(tld1.t_average == tld2.t_average));
    
    
    tld3.t_average = tld1.t_average;
    tld3.counter = tld1.counter + tld2.counter -1;
    
    tld1.subjectid = strcat(strcat(tld1.dataset_label,'_'),tld1.subjectid);
    tld2.subjectid = strcat(strcat(tld2.dataset_label,'_'),tld2.subjectid);
    tld3.subjectid = cat(1,tld1.subjectid,tld2.subjectid);

    tld1.studyid = arrayfun(@(x) num2str(x), tld1.studyid, 'UniformOutput', false);
    tld2.studyid = arrayfun(@(x) num2str(x), tld2.studyid, 'UniformOutput', false);
    tld3.studyid = cat(1,tld1.studyid,tld2.studyid);

    tld3.dataset_label = sprintf('%s+%s',tld1.dataset_label,tld2.dataset_label);
end

