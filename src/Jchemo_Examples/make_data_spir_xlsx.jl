using JLD2, XLSX, DataFrames

root = "D:/Mes Donnees/Users/Applications/Nirs/Data/Staff/Bonnal/Datasets_2021_09_24/"

#################### STEMS AND LEAFS

db = string(root, "Base_Sorgho.xlsx") 

dat = XLSX.readxlsx(db) ;
z = dat["Tiges&Feuilles X"] ;
v = z["A1:ZY1484"] ;
nam = v[1, 2:end] 
X = DataFrame(Float64.(v[2:end, 2:end]), Symbol.(nam)) 
id = string.(v[2:end, 1])
z = dat["Tiges&Feuilles Y"] 
v = z["A1:J1484"] ;
nam = lowercase.(v[1, 2:end]) 
Y = DataFrame(Float64.(v[2:end, 2:end]), Symbol.(nam)) 
id_Y = string.(v[2:end, 1])
allowmissing!(Y) ;
for col in eachcol(Y)
    replace!(col, 0 => missing)
end
znam = sort(names(Y)) 
Y = Y[:, znam] 

### Check consistency of IDs
s = findall(id .!= id_Y)
DataFrame((id_X = id[s], id_Y = id_Y[s]))
### End

dat = (X = X, Y = Y, id = id) ;

db = string(root, "sorghum_stemleaf.jld2") 
#@save db dat   

#################### PANICLES

db = string(root, "Base_Sorgho.xlsx") 

dat = XLSX.readxlsx(db) ;
z = dat["Panicules X"] ;
v = z["A1:ZY129"] ;
nam = v[1, 2:end] 
X = DataFrame(Float64.(v[2:end, 2:end]), Symbol.(nam)) 
id = string.(v[2:end, 1])
z = dat["Panicules Y"] 
v = z["A1:J129"] ;
nam = lowercase.(v[1, 2:end]) 
Y = DataFrame(Float64.(v[2:end, 2:end]), Symbol.(nam)) 
id_Y = string.(v[2:end, 1])
allowmissing!(Y) ;
for col in eachcol(Y)
    replace!(col, 0 => missing)
end
znam = sort(names(Y)) 
Y = Y[:, znam] 

### Check consistency of IDs
s = findall(id .!= id_Y)
DataFrame((id_X = id[s], id_Y = id_Y[s]))
### End

dat = (X = X, Y = Y, id = id) ;

db = string(root, "sorghum_pan.jld2") ;
#@save db dat   

