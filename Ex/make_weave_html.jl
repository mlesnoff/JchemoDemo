using Weave

## Global paths
path = "C:/Users/lesnoff/.julia/dev"
path_jmd = joinpath(path, "JchemoDemo/Ex/jmd")
path_html = joinpath(path, "JchemoDemo/docs/src/assets/html")
## End


nam = "Exploratory/Pca"
zpath = joinpath(path_jmd, nam)
@show f = filter(endswith("jmd"), readdir(zpath))
nf = length(f) 
for i = 1:nf 
    #i = 2
    @show string("-------- script:", i)
    @show f[i]
    #i = 11
    f[i]
    db = joinpath(zpath, f[i])
    out_path = joinpath(path_html, nam)
    println("Time")
    @time weave(db; out_path = out_path, doctype = "md2html", fig_path = nothing, fig_ext = nothing)
end



C:\Users\lesnoff\.julia\dev\JchemoDemo\Ex\jmd\Exploratory\Pca








nam = "cassav"
#nam = "challenge2018"
#nam = "corn"
#nam = "forages2"
#nam = "iris"
#nam = "mnist20pct"
#nam = "multifruit"
#nam = "octane"
#nam = "swissroll"
#nam = "tecator"
#nam = "wines_sensory"
zpath = joinpath(path_jmd, nam)
@show f = filter(endswith("jmd"), readdir(zpath))
nf = length(f) 
for i = 6:6 #1:nf 
    @show i
    @show f[i]
    #i = 11
    f[i]
    db = joinpath(zpath, f[i])
    out_path = joinpath(path_html, nam)
    println("Time")
    @time weave(db; out_path = out_path, doctype = "md2html", fig_path = nothing, fig_ext = nothing)
end


