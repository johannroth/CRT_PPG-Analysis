function [ xRegression, yRegression, rSquared, quadraticCoeff] = calculateRegression( x, y )
%CALCULATEREGRESSIONS calculates regression values of polyfit for the given
% scatterplotData
%   Parameters:
%       x (vector [n x 1])
%           Vector containing n x-values for regression
%       y (vector [n x 1])
%           Vector containing corresponding n y-values for regression
%   Returns:
%       xRegression (vector [1 x n])
%           Vector of length n containing values of stimulation intervals
%           for plotting the regression curve
%       yRegression (vector [1 x n])
%           Vector of length n containing values of the fitted curve
%           corresponding to xRegression values
%       rSquared (double)
%           Coefficient of determination for quadratic regression. Measure
%           of quality of the fit. (see [1], page 57)
%       quadraticCoeff (vector [1x3])
%           Coefficients of quadratic equation fitted to the scatterplot
%           beginning with highest coefficient a for parbola ax^2 + bx + c
%
%
% [1]   Urban, D., & Mayerl, J. (2011). Regressionsanalyse: Theorie,
%       Technik und Anwendung. Wiesbaden: VS Verlag für
%       Sozialwissenschaften. doi:10.1007/978-3-531-93114-2
%
% Author: Johann Roth
% Date: 05.01.2016

quadraticCoeff = polyfit(x,y,2);

xRegression = linspace(min(x)-20,max(x)+20);
yRegression = polyval(quadraticCoeff, xRegression);

%% Calculation of rSquared

% estimated values by regression
yEstimated = polyval(quadraticCoeff, x);

residuals = y - yEstimated;
yMean = mean(y);

% figure;
% plot(x,y,'k*');
% hold on;
% plot(xRegression,yRegression,'r');

% rSquared is defined as quotient of model defined variance
% and observed variance (compare [1] p. 55ff.)

rSquared = sum( (yEstimated-yMean).^2 )/sum( (y-yMean).^2 );




end