
using Jchemo, JchemoData    
using JLD2, CSV, DataFrames


path_jdat = dirname(dirname(pathof(JchemoData)))   # automatically detect the path where Julia has installed package JchemoData
db = joinpath(path_jdat, "data/tecator.jld2")      # full path to the jld2 file; can be changed to any other existing .jld2 file 
## Same as:   db = string(path_jdat, "\\data\\tecator.jld2")


@load db dat   # same as:    dat = load(db, "dat") 
@names dat     # @names is a Jchemo function


@head dat.X


@head dat.Y


res = load(db)  
keys(res)


dat = res["dat"] 
@names dat


db = joinpath(path_jdat, "data/cassav_X.csv")       # full path to the CSV file; can be changed to any other existing .CSV file 
X = CSV.read(db, DataFrame; header = 1, decimal = '.', delim = ';')  # same as below:
#X = CSV.File(db; header = 1, delim = ';') |> DataFrame 
#X = DataFrame(CSV.File(db, header = 1, delim = ';'))
@head X


db = joinpath(path_jdat, "data/cassav_Y.csv")      # full path to the CSV file; can be changed to any other existing .CSV file 
Y = CSV.read(db, DataFrame; header = 1, decimal = '.', delim = ';')
@head Y


dat = (X = X, Y)  # create a tuple with the dataframes
@names dat


path_out = tempdir()   # path receiving the result file; can be changed to any other existing path
db_out = joinpath(path_out, "my_cassav.jld2")  
@save db_out dat       # same as below:
#jldsave(db_out; dat)  
#jldsave(db_out, true; dat)  # 'true" ==> compression


db = joinpath(path_jdat, "data/tecator.jld2")  # full path to the jld2 file; can be changed to any other existing .jld2 file 
@load db dat
@names dat


path_out = tempdir()   # path that will receive the result file; can be changed to any other existing path
db_out = joinpath(path_out, "X.csv")
CSV.write(db_out, dat.X; delim = ";") # same as:  :dat.X |> CSV.write(db_out; delim = ";")


db_out = joinpath(path_out, "Y.csv")
CSV.write(db_out, dat.X; delim = ";")

