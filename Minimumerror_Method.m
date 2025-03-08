
function [ minErrorThreshold, varargout ] = minerrthresh(img,varargin)
tStart = cputime;
if any(strcmpi(varargin,'bin'))
    num_histogramBins = varargin{find(strcmpi(varargin,'bin'))+1};
else
    num_histogramBins = 128;
end
if any(strcmpi(varargin,'Gaussian'))
    errorFunctionGaus = zeros(num_histogramBins);
    useGaussian = 1;
else
    errorFunctionPois = zeros(num_histogramBins);
    useGaussian = 0;
end
img = double(img);
binMultiplier = double(num_histogramBins)/(max(img(:))-min(img(:)));
if exist('histcounts')
    [relativeFrequency, edges] = histcounts(img,num_histogramBins,...
        'BinLimits', [min(img(:)),max(img(:))],'Normalization', 'probability');
else
    binRange = min(img(:)): range(img(:))/(num_histogramBins-1) : max(img(:));
    relativeFrequency = histc(img(:),binRange)/numel(img);
end
totalMean = sum((1: num_histogramBins).*relativeFrequency);
for jj = 2:num_histogramBins-1
        priorLeft = eps; 
    meanLeft = double(0);
    varLeft = double(0);
    for ii = 1:jj
        priorLeft = priorLeft + relativeFrequency(ii);
        meanLeft = meanLeft + (ii-1)*relativeFrequency(ii);
    end
    meanLeft = meanLeft/priorLeft;
    for ii = 1:jj
        varLeft = varLeft + (ii-1-meanLeft)^2 * relativeFrequency(ii);
    end
    varLeft = varLeft/priorLeft;
    stdLeft = sqrt(varLeft)+eps;
    priorRight = eps; 
    meanRight = double(0);
    varRight = double(0);
    for ii = jj+1 : num_histogramBins
        priorRight = priorRight + relativeFrequency(ii);
        meanRight = meanRight + (ii-1)*relativeFrequency(ii);
    end
    meanRight = meanRight/priorRight;
    for ii = jj+1 : num_histogramBins
        varRight = varRight + (ii-1-meanRight)^2 * relativeFrequency(ii);
    end
    varRight = varRight/priorRight;
    stdRight = sqrt(varRight)+eps;
    if useGaussian == 0
        errorFunctionPois(jj) = totalMean...
            - priorLeft*(log(priorLeft)+meanLeft*log(meanLeft))...
            - priorRight*(log(priorRight)+meanRight*log(meanRight));
    else
        errorFunctionGaus(jj) = 1 + 2*(priorLeft*log(stdLeft)+priorRight*log(stdRight))...
            - 2*(priorLeft*log(priorLeft)+priorRight*log(priorRight));
    end
end
ii = 2;
if useGaussian == 0
    for jj = 3 : 127
        if errorFunctionPois(jj)<errorFunctionPois(ii), ii = jj; end
    end
else
    for jj = 3 : 127
        if errorFunctionGaus(jj)<errorFunctionGaus(ii), ii = jj; end
    end
end
minErrorThreshold = double(min(img(:))) + ii/binMultiplier;
disp(minErrorThreshold);
if nargout > 1
    stats.priorLeft = double(0);
    stats.alphaLeft = double(0);
    stats.priorRight = double(0);
    stats.alphaRight = double(0);
    for jj = 1:ii+1
        stats.priorLeft = stats.priorLeft + relativeFrequency(jj);
        stats.alphaLeft = stats.alphaLeft + jj*relativeFrequency(jj);
    end
    stats.alphaLeft = stats.alphaLeft / stats.priorLeft;
    for jj = ii+2 : num_histogramBins
        stats.priorRight = stats.priorRight + relativeFrequency(jj);
        stats.alphaRight = stats.alphaRight + jj*relativeFrequency(jj);
    end
    stats.alphaRight = stats.alphaRight / stats.priorRight;
    
    if useGaussian == 1
        stats.varLeft = double(0);
        for jj = 1:ii+1
            stats.varLeft = stats.varLeft + (jj-stats.alphaLeft)^2 + relativeFrequency(jj);
        end
        stats.varLeft = stats.varLeft / stats.priorLeft;
        stats.stdLeft = sqrt(stats.varLeft);
    
        stats.varRight = double(0);
        for jj = ii+2 : num_histogramBins
            stats.varRight = stats.varRight + (jj-stats.alphaRight)^2 + relativeFrequency(jj);
        end
        stats.varRight = stats.varRight / stats.priorRight;
        stats.stdRight = sqrt(stats.varRight);
        stats.alphaLeft = double(min(img(:))) + (stats.alphaLeft+1)/binMultiplier;
        stats.alphaRight = double(min(img(:))) + (stats.alphaRight+1)/binMultiplier;
        stats.stdLeft = stats.stdLeft / binMultiplier;
        stats.stdRight = stats.stdRight / binMultiplier;
    end
    varargout{1} = stats;
end
tEnd = cputime - tStart;
disp(tEnd)