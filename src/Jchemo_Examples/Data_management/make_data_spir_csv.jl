## Build a JLD2 dataset from a NIR csv file 

using JLD2, CSV, DataFrames
using Jchemo, JchemoData

mypath = dirname(dirname(pathof(JchemoData)))
root = "D:/Mes Donnees/Tmp/"

## X
db = joinpath(mypath, "data", "datspir_X.csv")  
df = CSV.read(db, DataFrame; header = 1, decimal = ',', 
    delim = ';') 
X = df[:, 2:end]
id = df.ID
## Y
db = joinpath(mypath, "data", "datspir_Y.csv")  
df = CSV.read(db, DataFrame; header = 1, decimal = ',', 
    delim = ';') 
Y = df[:, 2:end]
id_Y = df.ID
## To make sure that Y has lowercase names
nam = lowercase.(names(Y))
rename!(Y, nam)
## End
allowmissing!(Y) 
for j = 1:3
    Y[:, j] = replace(Y[:, j], 0 => missing)
end
## This would work if column "test" was not presnt:
## for col in eachcol(Y)
##    replace!(col, 0 => missing)
## end
## End
Y
## M
db = joinpath(mypath, "data", "datspir_M.csv")  
df = CSV.read(db, DataFrame; header = 1, decimal = ',', 
    delim = ';') 
M = df[:, 2:end]
id_M = df.ID
## To make sure that M has lowercase names
nam = lowercase.(names(M))
rename!(M, nam)
## End

#### Check consistency of IDs
s = id .!= id_Y
DataFrame((id_X = id[s], id_Y = id_Y[s]))
s = id .!= id_M
DataFrame((id_X = id[s], id_M = id_Y[s]))
#### Check duplicated ids
res = tab(id) 
lev = res.keys
z = res.vals
s = z .> 1
DataFrame((ID = lev[s], Nb = z[s]))
#### Check duplicated rows 
u = 1:50:nco(X)
checkdupl(X[:, u])
checkdupl(Y)
checkdupl(hcat(X[:, u], Y))
### End

dat = (X = X, Y, M, id) 

db = string(root, "datspir.jld2") 
#@save db dat   


