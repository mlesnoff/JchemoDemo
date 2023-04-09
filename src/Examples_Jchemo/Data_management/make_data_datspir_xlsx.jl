using JLD2, XLSX, DataFrames
using Jchemo, JchemoData

root_out = "D:/Mes Donnees/Tmp/"

path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data", "datspir.xlsx")  

dat = XLSX.readxlsx(db) 
## X
z = dat["X"] 
v = z["A1:ZY13"]  # or: v = z[:] when good delimitations
nam = v[1, 2:end] 
X = DataFrame(Float64.(v[2:end, 2:end]), Symbol.(nam)) 
id = string.(v[2:end, 1])
## Y
z = dat["Y"] 
v = z["A1:E13"] 
nam = lowercase.(v[1, 2:end]) 
Y = DataFrame(Float64.(v[2:end, 2:end]), Symbol.(nam)) 
id_Y = string.(v[2:end, 1])
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
z = dat["M"] 
v = z["A1:C13"] 
id_M = string.(v[2:end, 1])
nam = lowercase.(v[1, 2:end]) 
M = DataFrame(v[2:end, 2:end], Symbol.(nam))

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

db = string(root_out, "datspir.jld2") 
#@save db dat   


