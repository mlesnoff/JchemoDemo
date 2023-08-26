using Literate

path = "C:/Users/lesnoff/.julia/dev/JchemoDemo"

path_src = joinpath(path, "Examples_Jchemo/src")
path_ipynb = joinpath(path, "Examples_Jchemo/ipynb")

meth = "Regression"
zpath = joinpath(path_src, meth)
f = filter(endswith("jl"), readdir(zpath))
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






## src 
path_out = joinpath(path_src, meth)
Literate.script(db, path_out; credit = false)









db = joinpath(path, "ex1_literate.jl")
## Build a .md
Literate.markdown(db, path_out; 
    name = "res_ex1_literate_documenter",
    execute = false,    # 'true' not necessary for Documenter
    flavor = Literate.DocumenterFlavor(),    
    )
Literate.markdown(db, path_out; 
    name = "res_ex1_literate_documenter_exec",
    execute = true,    # 'true' not necessary for Documenter
    flavor = Literate.DocumenterFlavor(),    
    )
## Build a .jl
Literate.script(db, path_out;
    name = "res_ex1_literate",   # default = same name as inputfile
    keep_comments = true,        # default = false
    credit = false)
## Build a .ipynb
Literate.notebook(db, path_out;)


Literate.markdown(db, path_out; 
    name = "menu1",
    execute = true,    # 'true' not necessary for Documenter
    flavor = Literate.FranklinFlavor(),    
    )
