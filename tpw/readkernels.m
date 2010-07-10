function [Kph,Kam,x,y]=readkernels(file)
%READKERNELS    Reads sensitivity kernels for Yang & Forsyth codes
%
%    Usage:    [Kph,Kam,x,y]=readkernels(file)
%
%    Description: [Kph,Kam,X,Y]=READKERNELS(FILE) reads in the kernels
%     stored in FILE.  FILE should be a file on the system.  FILE is
%     expected to be formatted to work with Yang & Forsyth fortran
%     routines.  FILE may be empty to bring up a graphical file selection
%     menu.  Kph, Kam, X, Y are equal-sized numeric arrays giving the phase
%     sensitivity kernel, the amplitude sensitivity kernel, the x-direction
%     (radial) position and the y-direction (azimuthal or transverse)
%     position respectively.  Checks are performed to assure the kernel
%     file is properly formatted.
%
%    Notes:
%
%    Examples:
%     Check that a kernel is formatted correctly:
%      readkernels('my.kernel');
%
%    See also: WRITEKERNELS, MAKEKERNELS, RAYLEIGH_2D_PLANE_WAVE_KERNELS,
%              GETMAINLOBE, SMOOTH2D, PLOTKERNELS

%     Version History:
%        Feb.  5, 2010 - initial version
%        July  9, 2010 - fixed nargchk
%
%     Written by Garrett Euler (ggeuler at wustl dot edu)
%     Last Updated July  9, 2010 at 18:00 GMT

% todo:

% check nargin
msg=nargchk(0,1,nargin);
if(~isempty(msg)); error(msg); end

% graphical selection
if(nargin<1 || isempty(file))
    [file,path]=uigetfile(...
        {'*.kernel;*.KERNEL;kernel.*;KERNEL.*;' ...
        'Kernel Files (*.kernel,KERNEL.*)';
        '*.kern;*.KERN;kern.*;KERN.*;' ...
        'Kern Files (*.kern,KERN.*)';
        '*.dat;*.DAT' 'DAT Files (*.dat,*.DAT)';
        '*.*' 'All Files (*.*)'},...
        'Select Kernel File');
    if(isequal(0,file))
        error('seizmo:readkernels:noFileSelected',...
            'No input file selected!');
    end
    file=strcat(path,filesep,file);
else
    % check file
    if(~ischar(file))
        error('seizmo:readkernels:fileNotString',...
            'FILE must be a string!');
    end
    if(~exist(file,'file'))
        error('seizmo:readkernels:fileDoesNotExist',...
            'File: %s\nDoes Not Exist!',file);
    elseif(exist(file,'dir'))
        error('seizmo:readkernels:dirConflict',...
            'File: %s\nIs A Directory!',file);
    end
end

% open file for reading
fid=fopen(file);

% check if file is openable
if(fid<0)
    error('seizmo:readkernels:cannotOpenFile',...
        'File: %s\nNot Openable!',file);
end

% read in file and close
txt=fread(fid,'*char');
fclose(fid);

% row vector
txt=txt';

% parse and convert to double
v=str2double(getwords(txt));

% check number of elements
nv=numel(v);
if(mod(nv-6,4) || nv<10)
    error('seizmo:readkernels:malformedKernel',...
        'File: %s\nKernel is malformed!',file);
end

% get header info
nx=v(1); bx=v(2); dx=v(3);
ny=v(4); by=v(5); dy=v(6);

% cut off header
v(1:6)=[];

% push values into properly oriented arrays
x=reshape(v(1:4:end),[ny nx]);
y=reshape(v(2:4:end),[ny nx]);
Kph=reshape(v(3:4:end),[ny nx]);
Kam=reshape(v(4:4:end),[ny nx]);

% check position consistency
dx2=unique(diff(x,1,2));
dy2=unique(diff(y,1,1));
if(~isscalar(dx2) || dx2<=0)
    error('seizmo:writekernels:badInput',...
        'X step size is not uniform or is <=0!');
elseif(~isscalar(dy2) || dy2<=0)
    error('seizmo:writekernels:badInput',...
        'Y step size is not uniform or is <=0!');
elseif(dx2~=dx || x(1)~=bx)
    error('seizmo:writekernels:badInput',...
        'X header info does not match data!');
elseif(dy2~=dy || y(1)~=by)
    error('seizmo:writekernels:badInput',...
        'Y header info does not match data!');
end

end
