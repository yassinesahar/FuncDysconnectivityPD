function  PlotCorrelation_withColor(X,Y,color)
% This function plots the correlation between X and Y in color (rgb vector)


nonans=(isnan(X)==0 & isnan(Y)==0);
X=X(nonans);Y=Y(nonans);
[XSorted,ind]=sort(X);
YSorted=Y(ind);

[c,p]=corr(XSorted,YSorted);

fitResults = fit(XSorted,YSorted,'poly1');
po=polyfit(XSorted,YSorted,1);

figure,plot(XSorted,YSorted,'.','MarkerSize',14,'Color',color);
a= axis;

xx=a(1):0.1:a(2);
xx=xx';
f = polyval(po,xx);

p95=predint(fitResults,xx,0.95,'functional','on');
upper=p95(:,1);lower=p95(:,2);



mea=MAE(X,Y);
boundUp=f+mea;
boundLow=f-mea;

%xlim=[min(X) max(X)];
%ylim=[-maxAbsY-0.5 maxAbsY+0.5];



filled=[upper',fliplr(lower')];
xpoints=[xx',fliplr(xx')];
transparency=0.15;

xlim=[min(X)-1 max(X)+1];
ylim=[min(filled) max(filled)];


hold on, plot(xx,f,'-','Color',color,'LineWidth',1);
% hold on, plot(xx,boundUp,'-.','Color',color);
% hold on, plot(xx,boundLow,'-.','Color',color);
hold on,fillhandle=fill(xpoints,filled,color);%plot the data
set(fillhandle,'EdgeColor',color,'FaceAlpha',transparency,'EdgeAlpha',transparency);%set edge color
%axis([xlim ylim]);

end