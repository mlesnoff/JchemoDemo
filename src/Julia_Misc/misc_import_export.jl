using CSV, HDF5, JLD2, MAT, XLSX, DataFrames
using RData, CodecXz      # RData requires CodecXz
using JSON
using JchemoData
 
mypath = dirname(dirname(pathof(JchemoData)))
root = "D:/Mes Donnees/Tmp/"

########### CSV

## Importation
db = joinpath(mypath, "data", "dat_2021.csv") 
## Same as: 
## db = string(mypath, "\\data\\dat_2021.csv")
## End
df = CSV.read(db, DataFrame; header = 1, decimal = '.', 
    delim = ';') 
# Same as:
#df = CSV.File(db; header = 1, delim = ';') |> DataFrame 
#df = DataFrame(CSV.File(db, header = 1, delim = ';'))
size(df)
names(df)

## Exportation
X = reshape([missing ; rand(9)], 5, 2)
X = DataFrame(X, :auto)
file = string(root, "res.csv")
CSV.write(file, X; delim = ";")
file = string(root, "res2.csv")
CSV.write(file, X; delim = ';',  missingstring =  "0.0")

# See also syntax:
#X |> CSV.write(file; kwargs...)

########### JLD2 

## Importation
db = joinpath(mypath, "data", "cassav.jld2") 
@load db dat
keys(dat)
dat.X

## Exportation
X1 = rand(5, 3)
X2 = DataFrame(rand(5, 2), ["y1", "y2"]) 
info = "Fictive data"
dat = (X1 = X1, X2 = X2, info = info)
db = string(root, "res.jld2") 
@save db dat 
#@load db dat ; keys(dat)

########### HDF5
## HDF5 stands for Hierarchical Data Format v5 and is closely 
## modeled on file systems. In HDF5, a "group" is analogous to a directory, 
## a "dataset" is like a file. HDF5 also uses "attributes" to associate metadata 
## with a particular group or dataset. 

## h5open()
## mode	Meaning
## "r"	read-only
## "r+"	read-write, preserving any existing contents
## "cw"	read-write, create file if not existing, preserve existing contents
## "w"	read-write, destroying any existing contents (if any)

## Exportation
X = rand(5, 8) 
y = collect(1:3) 
z = ["b", "d", "a", "u"] 
db = string(root, "res.h5")
#db = tempname() # temporary file
fid = h5open(db, "w")
HDF5.write(fid, "X", X)
HDF5.write(fid, "y", y)
fid["z"] = z 
fid
HDF5.write(fid, "All/X", X)
HDF5.write(fid, "All/y", y)
fid
HDF5.close(fid)

## Importation
fid = h5open(db, "r")
fid["X"]
HDF5.read(fid["X"])
HDF5.read(fid, "X")
HDF5.read(fid["z"])
HDF5.read(fid["All"])
HDF5.read(fid["All/y"])
HDF5.filename(fid)
HDF5.name(fid)
HDF5.close(fid)

fid = h5open(db, "r")
for obj in fid
    dat = HDF5.read(obj)
    println(dat)
end
HDF5.close(fid)

fid = h5open(db, "cw")
HDF5.delete_object(fid["X"])
fid
fid["X"] = 5 
fid
HDF5.read(fid["X"])
HDF5.close(fid)

########### JSON

## Importation
db = joinpath(mypath, "data", "dat2.json") 
z = read(db, String)
z = JSON.parse(z)
z = JSON.parse(z[1])
res = DataFrame(z)

db = joinpath(mypath, "data", "dat.json") 
z = read(db, String)
z = JSON.parse(z)
DataFrame(zdat)

dat = """
{"id":[92084,92085,92086],"1100":[0.0978,0.1024,0.0798],
"1102":[0.0977,0.1021,0.0797],"1104":[0.0976,0.1019,0.0797],
"1106":[0.0975,0.1018,0.0796]}
"""
zdat = JSON.parse(dat)
res = DataFrame(zdat)
res[!, 1] = string.(res[:, 1])
res[!, 2:end] = convert.(Float64, res[:, 2:end])
#res[!, 2:end] = convert.(Float64, res[!, 2:end])
res

########### MAT 

## Package MAT can only read Matlab files, 
## not save data in the Matlab format  

## Importation
db = joinpath(mypath, "data", "mango.mat") 
dat = matopen(db)
keys(dat)
Xcal = read(dat, "SP_cal")
Ycal = read(dat, "DM_cal")
close(dat)
# Same as:
dat = matread(db) 
keys(dat)
Xcal = dat["SP_cal"] 
Ycal = dat["SP_cal"]

db = joinpath(mypath, "data", "machine.mat") 
dat = matopen(db)
keys(dat)
z = read(dat, "LAMDATA") 
z["INFORMATION"]
Xcal = z["calibration"]
Xcal = reduce(vcat, Xcal)
close(dat)

dat = matread(db) ;
keys(dat)
z = dat["LAMDATA"] 
keys(z)

########### RData

## Importation
db = joinpath(mypath, "data", "octane.rda") 
dat = load(db)
keys(dat)
z = dat["octane"] ;
keys(z)
## Same as
## z = get(dat, "datoctane", nothing) ;
X = z["X"] 
size(X)

db = joinpath(mypath, "data", "cassav.rda") 
dat = load(db)
keys(dat)
z = dat["cassav"] ;
keys(z)
year = z["year"]
Xtrain = z["Xtrain"]
ytrain = z["ytrain"] 
Xtest = z["Xtest"]
ytest = z["ytest"]

########### XLSX 

## Importation
db = joinpath(mypath, "data", "tecator.xlsx") 
dat = XLSX.readxlsx(db) 
nam = XLSX.sheetnames(dat)
z = dat["X Cal"]
#z = dat[nam[1]]
Xcal = z[:]
z["A1:CV158"]
z[2, 2]
z = dat["Y cal"]
Ycal = z[:]
# Same as:
Xcal = XLSX.readdata(db, "X Cal", "A1:CV158")

## Exportation
X1 = DataFrame(rand(5, 3), :auto)
X2 = DataFrame(rand(5, 2), ["y1", "y2"]) 
db = string(root, "res.xlsx") 
XLSX.writetable(db, 
    Xcal  = (collect(DataFrames.eachcol(X1)), DataFrames.names(X1)), 
    Ycal = (collect(DataFrames.eachcol(X2)), DataFrames.names(X2)),
    overwrite = true)


