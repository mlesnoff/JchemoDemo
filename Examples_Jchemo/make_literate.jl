using Literate

path = "C:/Users/lesnoff/.julia/dev/JchemoDemo"

path_src = joinpath(path, "Examples_Jchemo/src")
path_ipynb = joinpath(path, "Examples_Jchemo/ipynb")

#meth = "Exploratory"
#meth = "Regression"
meth = "Discrimination"
#meth = "Dataset_description"
zpath = joinpath(path_src, meth)
@show f = filter(endswith("jl"), readdir(zpath))
nf = length(f) 
for i = 1:nf 
    @show i
    @show f[i]
    #i = 11
    f[i]
    db = joinpath(zpath, f[i])
    path_out = joinpath(path_ipynb, meth)
    println("Time")
    @time Literate.notebook(db, path_out;)
end
