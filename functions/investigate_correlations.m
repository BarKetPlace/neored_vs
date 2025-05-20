folder = '/Volumes/Coen_backup/Data/transfusion/';
%folder='~/Documents/';
data_table=readtable(strcat(folder,"hr_mean.xlsx"));
%data_table=readtable(strcat(folder,"hr_std.xlsx"));
%data_table=readtable(strcat(folder,"sats_mean.xlsx"));
%data_table=readtable(strcat(folder,"rr_mean.xlsx"));
%data_table=readtable(strcat(folder,"sats_std.xlsx"));
%data_table=readtable(strcat(folder,"rr_std.xlsx"));

%demographics
sex=categorical(data_table.BIRTH_Gender);
PMA=data_table.PMA;
weight=data_table.TESTOD_MostRecentWeight;
ventilation=categorical(data_table.TESTOD_CurrentVentilation);
PNA=data_table.PNA;

%transfusion
starthb=data_table.StartHB;
%endhb=data_table.EndHB;
%diffhb=data_table.diffHb;

%metrics
increase=data_table.AverageSignalIncrease;
decrease=data_table.AverageSignalDecrease;
overall=increase-decrease;

%%
% t=table(PMA,weight,ventilation,diffhb,increase);
% mdl=fitlm(t,'ResponseVar','increase')
% 
% t=table(PMA,weight,ventilation,diffhb,decrease);
% mdl=fitlm(t,'ResponseVar','decrease')

response=overall;
% response=-decrease;
% response=increase;

t=table(PMA,PNA,weight,ventilation,starthb,response);

mdl=fitlm(t,'response~PMA*PNA*starthb')
%mdl=fitlm(t,'response~ventilation+weight+diffhb')

%figure; plotAdjustedResponse(mdl,'weight')

%%

figure; 
subplot(2,3,1); scatter(sex,response,'filled'); xlabel('sex','fontsize',15); set(gca,'fontsize',15)
subplot(2,3,2); scatter(PMA,response,'filled'); lsline; xlabel('PMA','fontsize',15); set(gca,'fontsize',15)
subplot(2,3,3); scatter(PNA,response,'filled'); lsline; xlabel('PNA','fontsize',15); set(gca,'fontsize',15)
subplot(2,3,4); scatter(ventilation,response,'filled'); xlabel('ventilation mode','fontsize',15); set(gca,'fontsize',15)
subplot(2,3,5); scatter(weight,response,'filled'); lsline; xlabel('weight','fontsize',15); set(gca,'fontsize',15)
subplot(2,3,6); scatter(starthb,response,'filled'); lsline; xlabel('starthb','fontsize',15); set(gca,'fontsize',15)

