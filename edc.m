function [rt60, curve] = edc(h, fs, start_time, finish_time,ax,ms_measured)
% function Y= edc(h,fs, start_time, finish_time)
% estimates the reveberation time (RT_60) by performing
% a linear fit to a segement of the energy decay curve (edc).
%
% Input parameters:
%       h :         a vector containing the impulse response.
%       fs:         the sampling frequency [Hz] a scalar
%       start_time: (optional) the start of segement used
%                       for estimation [sec].  (scalar)
%       end_time:   (optional) the end of segement used
%                       for estimation [sec].  (scalar)
%
% Output parameters:
%       rt_60:     estimated reverberation time. [sec] (scalar)
%       curve:   energy decay curve not normalized (optional)
%
% Notes:
%       For the output, the normalized EDC is displayed,
%       and the segement used for estimation is indicated.
%       It is important to verify that the section indicated,
%       is valid.
%       Since the EDC is noramlized, examination of the first
%       large drop can be used to esimate the direct to reverberant
%       ratio (DRR).
%
% Version: Beta_1.01
% Author:  Dovid Y. Levin
% Date:    2013_07_30
% History: Based on previous function used in graduation projecto of
%           Dovid Levin and Evyater Weisel (2008).
%
% Improvements and modifications (v_1.001:
%          * Optionally returns curve vector (not normalized)
% Improvements and modifications (v_1.00):
%          * EDC plotted in decibell units
%          * EDC normalized to start with 0 dB
%          * The function can optionaly take paramters specifying
%                  start and end of segement used for estimation.
%          * Plots the fitted decay.
%          * Adds some checks of valadity of input paramaters.
%          * h does not have to be a row vector.

% Test for valid input:
assert(length(h) == max(size(h)),...
         'Error: impulse response "h" must be a vector.');
assert(length(fs) == 1 && fs> 0,...
         'Error: sampling frequency "fs" must be a positive scalar.');
assert(nargin ~= 3,...
         'Error: If "Start_time" is specified, "finish_time" must also be specified.');

% Convert input into correct froms:
h_col = h(:); % If h is a row vector, convert to column.


%Create EDC vector by reverse cumulative sum of h_col.^2 : 
curve =10 * log10((flipud(cumsum(flipud(h_col.^2))))); %reverse cumulative sum
cs = curve -(curve(1));  % normalize EDC vector (to start at 0 dB). 

% Create time vector:
tt = (0:length(cs)-1)' ./fs;

% Determine indicies of for start and end of setimation interval:
if nargin < 3  % If start_time finish_time unspecified, use defualt values.
    start  = floor(0.1*length(cs));  % start of estimation interval
    finish = ceil(0.8*length(cs));   % end   of estimation inverval
else           % Use specified values
    start  = 1 + floor(start_time * fs);
    finish = 1 + ceil(finish_time * fs);
end

start = max([start, 1]);            % Enforce index in legal range.
finish= min([finish, length(cs)]);  % ".
    
% Perform least sqaures fit to segement.
coef=polyfit(tt(start:finish),cs(start:finish),1);

% Plot EDC and related data

plot (ax,tt(1:10:end), cs(1:10:end),'-b','linewidth',4); % plot energy decay curve.
hold(ax,'on');

plot(ax,[tt(start), tt(finish)],...
     coef(2) + coef(1) * [tt(start), tt(finish)],'c-','linewidth',6); % plosts fitted line.
hold(ax,'on');


rt60 = -60/coef(1);

ih = cs(1);      %interval height on plot
plot (ax,[tt(start), tt(finish)],[ih, ih],'r-','linewidth',4);
% title(ax,['estimated T_{60} - ',num2str(rt60),' | normalized EDC - verify that red line is above linear section']);
% set(ax,'FontSize',18);
title(ax,['Estimated T_{60} - ',num2str(rt60*1000),' ms',' | Room setup T_{60} - ',num2str(ms_measured), ' ms' ],'FontSize',14);
axis(ax,[0, tt(end), cs(end), ih+5]);
xlabel(ax,'time [sec]','FontSize',14);
ylabel(ax,'normalized EDC [dB]','FontSize',14);
set(ax,'FontSize',16);
grid(ax, 'on')
hold(ax, 'off');

% Output estimated RT60

disp(' ')
disp(['Estimated RT_60:  ', num2str(rt60), '  [sec].'])
disp(' ')

return