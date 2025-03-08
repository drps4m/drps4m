clc;
tStart = cputime;
load  A.mat;
sum = 0;
y = 0;
i=1;
j=1;
p = 474;
q = 474;

for m =2:3:p-1
    for n=2:3:q-1
        for b=j:1:j+2
            for a=i:1:i+2
                sum = A(a,b)+sum;
            end
        end
        z = (9*A(m,n)- sum)/8;
        x = abs(z);
        j = j+3;
        sum = 0;
        y = max(x, y);
    end
    i = i+3;
    j =1;
end
disp(y);
tEnd = cputime - tStart;
disp(tEnd);