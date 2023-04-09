using JLD2, CSV, DataFrames
using Jchemo, JchemoData

root_out = "D:/Mes Donnees/Tmp/"

path_jdat = dirname(dirname(pathof(JchemoData)))
## X
db = joinpath(path_jdat, "data", "datspir_X.csv")  
df = CSV.read(db, DataFrame; header = 1, decimal = ',', 
    delim = ';') 
X = df[:, 2:end]
id = df.ID
## Y
db = joinpath(path_jdat, "data", "datspir_Y.csv")  
df = CSV.read(db, DataFrame; header = 1, decimal = ',', 
    delim = ';') 
Y = df[:, 2:end]
id_Y = df.ID
## To make sure that Y has lowercase names
nam = lowercase.(names(Y))
rename!(Y, nam)
## End
allowmissing!(Y)  # to transform zero(s) to missing value(s) 
for j = 1:3
    Y[:, j] = replace(Y[:, j], 0 => missing)
end
## The command below would work if column "test" 
## was not present:
## for col in eachcol(Y)
##    replace!(col, 0 => missing)
## end
## End
Y
## M
db = joinpath(path_jdat, "data", "datspir_M.csv")  
df = CSV.read(db, DataFrame; header = 1, decimal = ',', 
    delim = ';') 
M = df[:, 2:end]
id_M = df.ID
## To make sure that M has lowercase names
nam = lowercase.(names(M))
rename!(M, nam)
## End

## Check consistency of IDs
s = id .!= id_Y
DataFrame((id_X = id[s], id_Y = id_Y[s]))
s = id .!= id_M
DataFrame((id_X = id[s], id_M = id_Y[s]))
## Check duplicated ids
tabdupl(id) 
## Check duplicated rows 
u = 1:50:nco(X)
checkdupl(X[:, u])
checkdupl(Y)
checkdupl(hcat(X[:, u], Y))
## End

dat = (X = X, Y, M, id) 

db = string(root, "datspir.jld2") 
#@save db dat   


