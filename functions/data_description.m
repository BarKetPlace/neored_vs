
function [descript_str] = data_description(data,dataname)
    n = size(data,2);
    descript_str = sprintf('%s: \t%.2f (%.2f-%.2f)\t M SD %.2f (%.2f) \t(Missing: %d/%d)', ...
        dataname, median(data,'omitnan'), min(data,[],'omitnan'),max(data,[],'omitnan'), mean(data,'omitnan'),std(data,'omitnan'), sum(isnan(data)),n);
    %if dataname == "Rates"
    fig=figure;
    hist(data,75)
    title(descript_str)
        
    %end
end   
