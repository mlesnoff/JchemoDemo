using Weave

path = "C:/Users/lesnoff/.julia/dev"

path_jmd = joinpath(path, "JchemoDemo/Ex/jmd")
path_html = joinpath(path, "JchemoDemo/docs/src/assets/html")

#meth = "Dataset"
#meth = "Exploratory"
meth = "Regression"
#meth = "Discrimination"
zpath = joinpath(path_jmd, meth)
@show f = filter(endswith("jmd"), readdir(zpath))
nf = length(f) 
for i = 14:14 #nf 
    @show i
    @show f[i]
    #i = 11
    f[i]
    db = joinpath(zpath, f[i])
    out_path = joinpath(path_html, meth)
    println("Time")
    @time weave(db; out_path = out_path, doctype = "md2html",
        fig_path = nothing, fig_ext = nothing)
end


