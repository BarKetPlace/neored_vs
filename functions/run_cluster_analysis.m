function run_cluster_analysis(tld,t_overlap,t_limits)
    pre = find(tld.t_average<0);
    post = find(tld.t_average>0);
    sig_quality = tld.sig_quality;
    
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

