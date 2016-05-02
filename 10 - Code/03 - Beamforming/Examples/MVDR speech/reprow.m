%Faster repmat function strictly for repeating rows.
function M=reprow(v,rows)
M=zeros(rows,length(v));
for row=1:rows
    M(row,:)=v;
end