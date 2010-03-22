function [data]=makeuneven(data)
%MAKEUNEVEN    Makes evenly-sampled SEIZMO records look like uneven ones
%
%    Usage:    data=makeuneven(data)
%
%    Description: DATA=MAKEUNEVEN(DATA) converts the evenly sampled records
%     in SEIZMO struct DATA so they follow the format of unevenly sampled
%     records.  This does not alter the timing of the records.  All that is
%     done is the timing of the data point-for-point is stored in the .ind
%     struct field and the header field LEVEN is changed to FALSE.  Comes
%     in handy if you want the data timing but don't want to go through the
%     steps to create it (beyond just running this).
%
%    Notes:
%     - Running MAKEUNEVEN on spectral records will throw errors the next
%       time CHECKHEADER is called on those records.
%
%    Header changes: LEVEN
%
%    Examples:
%     Make your own 'slideshow' of records:
%      figure;
%      data=makeuneven(data);
%      for i=1:numel(data)
%          plot(data(i).ind,data(i).dep);
%          pause(2);
%      end
%
%    See also: GETLGC, CHECKHEADER

%     Version History:
%        Mar. 19, 2010 - initial version
%
%     Written by Garrett Euler (ggeuler at wustl dot edu)
%     Last Updated Mar. 19, 2010 at 23:55 GMT

% todo:

% check nargin
msg=nargchk(1,1,nargin);
if(~isempty(msg)); error(msg); end

% check data structure
versioninfo(data,'dep');

% turn off struct checking
oldseizmocheckstate=seizmocheck_state(false);

% attempt to change even to uneven
try
    % check headers
    data=checkheader(data);
    
    % verbosity
    verbose=seizmoverbose;
    
    % fill .ind for evenly spaced arrays
    even=~strcmpi(getlgc(data,'leven'),'false');
    
    % are any are evenly spaced?
    if(any(even))
        % detail message
        if(verbose)
            disp('Converting Evenly Sampled Record(s) to Uneven Format');
        end
        
        % pull header values
        [b,delta,npts]=getheader(data(even),'b','delta','npts');
        
        % loop over even, add .ind
        idx=find(even);
        for i=1:sum(even)
            data(idx(i)).ind=b(i)+(0:npts(i)-1)'*delta(i);
        end
    end
    
    % set all to uneven
    data=changeheader(data,'leven',false);
    
    % toggle checking back
    seizmocheck_state(oldseizmocheckstate);
catch
    % toggle checking back
    seizmocheck_state(oldseizmocheckstate);

    % rethrow error
    error(lasterror)
end

end
