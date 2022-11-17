pwd()
homedir()
tempdir()

path = "D:/Mes Donnees/Users/Applications/Tools/" 
dirname(path)
readdir(path)
@__DIR__        # Directory where is the current file 
@__FILE__       # Name of the current file

joinpath("/home/myuser", "example.jl")
splitpath("/home/myuser/example.jl")
splitext("/home/myuser/example.jl")
basename("/home/myuser/example.jl")

using Jchemo
pathof(JchemoData)
dirname(pathof(JchemoData))
dirname(dirname(pathof(JchemoData)))
mypath = dirname(dirname(pathof(JchemoData)))
db = joinpath(mypath, "data", "iris.jld2")

#const path_data1 = joinpath(@__DIR__, "../data")
#const path_data2 = joinpath(dirname(@__FILE__), "..", "data")

## Source the files existing in a path
function fsource(path)
    z = readdir(path)  ## List of files in path
    n = length(z)
    for i in 1:n
        include(string(path, "/", z[i]))
    end
end

;  # ==> Shell 
.  # Current directory
.. # Above directory

