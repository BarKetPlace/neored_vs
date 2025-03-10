
function print_demographics(BIRTH_weight,BIRTH_Gender,PMA)
    n = size(BIRTH_weight,2);
    if n==0
        fprintf('No Data to print\n');
    else
        assert(size(BIRTH_Gender,2) == n);
        assert(size(PMA,2) == n);
        %B = regexp(BIRTH_Gender,'\S+','match');
        %T = cell2table([B{:}].');
        counts=[0,0,0];
        ic=1;
        for c = ['-','M','F']
            counts(ic) = sum(strcmp(BIRTH_Gender,c));
            ic = ic +1;
        end
    
        %BIRTH_Gender_table = groupsummary(T,'Var1');
        %if size(BIRTH_Gender_table,1)==2
        %    BIRTH_Gender_table = [{{'-'},0};BIRTH_Gender_table];
        %end
        
        BIRTH_Gender_str = sprintf('Gender:\t\t\tF: %d (%.2f), M: %d (%.2f)\t(Missing: %d/%d)',counts(3),counts(3)/(n-counts(1)),counts(2),counts(2)/(n-counts(1)), counts(1),n);
        PMA_str = sprintf('Birth PMA (weeks): \t%.2f (%.2f-%.2f)\t(Missing: %d/%d)', median(PMA,'omitnan'), min(PMA,[],'omitnan'),max(PMA,[],'omitnan'),sum(isnan(PMA)),n);
        BIRTH_weight_str = sprintf('Birth weight (g):\t%d (%d-%d)\t(Missing: %d/%d)', round(median(BIRTH_weight,'omitnan')), round(min(BIRTH_weight,[],'omitnan')),round(max(BIRTH_weight,[],'omitnan')),sum(isnan(BIRTH_weight)),n);
        fprintf('%s\n%s\n%s\n', PMA_str, BIRTH_weight_str, BIRTH_Gender_str);
    end
end
