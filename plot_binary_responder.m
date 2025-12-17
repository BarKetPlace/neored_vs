%folder = '/Volumes/Caroline_backup/Ox68/';
folder = strcat(plot_dir,'/tables/');
all_stems = ["hr_mean","hr_std","sats_mean","sats_std","rr_mean","rr_std"];
for fname_stem = all_stems
    %fname_stem = "sats_mean";
    
    %data_table=readtable(strcat(folder,"hr_mean.xlsx"));
    %data_table=readtable(strcat(folder,"hr_std.xlsx"));
    data_table = readtable(strcat(folder,fname_stem,sprintf('_%s.xlsx',dataset_label)));
    %data_table=readtable(strcat(folder,"rr_mean.xlsx"));
    %data_table=readtable(strcat(folder,"sats_std.xlsx"));
    %data_table=readtable(strcat(folder,"rr_std.xlsx"));
    %data_table.BIRTH_Gender = changem(data_table.BIRTH_Gender,77,'M');
    %demographics
    sex=categorical(data_table.BIRTH_Gender);
    PMA=data_table.PMA/7;
    PNA=data_table.PNA;
    weight=data_table.TESTOD_MostRecentWeight;
    ventilation=categorical(data_table.TESTOD_CurrentVentilation);
    
    %transfusion
    starthb=data_table.StartHB;
    endhb=data_table.EndHB;
    diffhb=endhb-starthb;
    
    
    %metrics
    increase_responder=data_table.IncreaseResponse;
    decrease_responder=data_table.DecreaseResponse;
    responder=increase_responder+decrease_responder;
    
    response=zeros(length(increase_responder),1);
    
    response(find(responder==0))=1;
    response(find(decrease_responder))=2;
    response(find(increase_responder))=3;
    
    %%

    fig=figure; boxplot(PMA,response); ylabel('PMA (weeks)','fontsize',15); set(gca,'XTickLabel',{'Non','Decrease','Increase'}); set(gca,'fontsize',15)
    %set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    title(fname_stem, 'Interpreter', 'none')
    exportgraphics(gcf, strcat(folder,fname_stem,'_boxplots_pma.jpg'));
    %print(strcat(folder,fname_stem,'_boxplots_pma.jpg'),'-dpdf','-bestfit')

    fig=figure; boxplot(PNA,response); ylabel('PNA (days)','fontsize',15); set(gca,'XTickLabel',{'Non','Decrease','Increase'}); set(gca,'fontsize',15)
    %set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    title(fname_stem, 'Interpreter', 'none')
    exportgraphics(gcf, strcat(folder,fname_stem,'_boxplots_pna.jpg'));
    %print(strcat(folder,fname_stem,'_boxplots_pma.jpg'),'-dpdf','-bestfit')


    fig=figure; boxplot(weight,response); ylabel('Weight (kg)','fontsize',15); set(gca,'fontsize',15); set(gca,'XTickLabel',{'Non','Decrease','Increase'});
    %set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    title(fname_stem, 'Interpreter', 'none')
    orient(fig, 'landscape')
    exportgraphics(gcf, strcat(folder,fname_stem,'_boxplots_weight.jpg'));
    %print(strcat(folder,fname_stem,'_boxplots_weight.jpg'),'-dpdf','-bestfit')

    fig=figure; boxplot(starthb,response); ylabel('Start Hb (g/l)','fontsize',15); set(gca,'fontsize',15); set(gca,'XTickLabel',{'Non','Decrease','Increase'});
    %set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    title(fname_stem, 'Interpreter', 'none')
    orient(fig, 'landscape')
    exportgraphics(gcf, strcat(folder,fname_stem,'_boxplots_starthb.jpg'));
    %print(strcat(folder,fname_stem,'_boxplots_starthb.jpg'), '-dpdf','-bestfit')

    fig=figure; boxplot(endhb,response); ylabel('End Hb (g/l)','fontsize',15); set(gca,'fontsize',15); set(gca,'XTickLabel',{'Non','Decrease','Increase'});
    %set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    title(fname_stem, 'Interpreter', 'none')
    orient(fig, 'landscape')
    exportgraphics(gcf, strcat(folder,fname_stem,'_boxplots_endhb.jpg'));
    %print(strcat(folder,fname_stem,'_boxplots_endhb.jpg'),'-dpdf','-bestfit')

    fig=figure; boxplot(diffhb,response); ylabel('Increment Hb (g/l)','fontsize',15); set(gca,'fontsize',15); set(gca,'XTickLabel',{'Non','Decrease','Increase'});
    %set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    title(fname_stem, 'Interpreter', 'none')
    orient(fig, 'landscape')
    exportgraphics(gcf, strcat(folder,fname_stem,'_boxplots_incrhb.jpg'));
    %print(strcat(folder,fname_stem,'_boxplots_incrhb.jpg'),'-dpdf','-bestfit')
    close all

        %% raincloud plots
    % Define group names and colors
    group_names = {'Non', 'Decrease', 'Increase'};

    % Distinct colors for each group in the same order:
    % 1 = Non (red), 2 = Decrease (blue), 3 = Increase (orange)
    colors = [
        1, 0.41, 0.38;        % Non (red)
        0.65, 0.77, 0.90;     % Decrease (blue)
        0.99, 150/255, 0      % Increase (orange)
        ];

    % Define data variables and labels
    variables = {PMA, PNA, weight, starthb, endhb, diffhb};
    ylabels = {'PMA (weeks)', 'PNA (days)', 'Weight (kg)', ...
        'Start Hb (g/l)', 'End Hb (g/l)', 'Increment Hb (g/l)'};
    filenames = {'_raincloud_pma.jpg', '_raincloud_pna.jpg', ...
        '_raincloud_weight.jpg', '_raincloud_starthb.jpg', ...
        '_raincloud_endhb.jpg', '_raincloud_incrhb.jpg'};

    % Loop over each variable
    for i = 1:length(variables)
        % Pre-check if there's any data at all
        skip = true;
        for g = 1:3
            data = variables{i}(response == g);
            data = data(~isnan(data));
            if ~isempty(data)
                skip = false;
                break;
            end
        end
        if skip
            fprintf('Skipping %s — no valid data.\n', ylabels{i});
            continue
        end

        % Compute global x-limits across all groups
        all_data = variables{i};
        all_data = all_data(~isnan(all_data));
        global_xlim = [prctile(all_data, 1) prctile(all_data, 99)];

        % Create figure
        fig = figure;
        for g = 1:3
            data = variables{i}(response == g);
            data = data(~isnan(data)); % remove NaNs

            if isempty(data)
                continue
            end

            % Store current axis limits to adjust after each plot
            curr_ylim = ylim;

            % Temporarily move axes for vertical stacking
            subplot(3, 1, g); hold on
            raincloud_plot(data, ...
                'color', colors(g,:), ...
                'box_on', 1, ...
                'box_col_match', 1, ...
                'box_dodge', 0, ...
                'dot_dodge_amount', 0.6, ...
                'alpha', 0.5,...
                'band_width', 0.1,...
                'x_limits', global_xlim);

            set(gca, 'YTick', [], 'fontsize', 13)
            ylabel(group_names{g}, 'fontsize', 13)
            box off
        end

        % Common x-label and title
        xlabel(ylabels{i}, 'fontsize', 15)
        sgtitle(fname_stem, 'Interpreter', 'none', 'fontsize', 16)

        % Save the figure
        exportgraphics(fig, strcat(folder, fname_stem, filenames{i}));
        close(fig)
    end

end

%%
%!pdftk ../results/tables/*pma.jpg cat output ../results/tables/pma_all.jpg
%!pdftk ../results/tables/*weight.jpg cat output ../results/tables/weight_all.jpg
%!pdftk ../results/tables/*starthb.jpg cat output ../results/tables/starthb_all.jpg
%!pdftk ../results/tables/*endhb.jpg cat output ../results/tables/endhb_all.jpg
%!pdftk ../results/tables/*incrhb.jpg cat output ../results/tables/incrhb_all.jpg
