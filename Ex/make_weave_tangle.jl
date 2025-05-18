using Weave

## Global paths
path = "C:/Users/lesnoff/.julia/dev"
path_jmd = joinpath(path, "JchemoDemo/Ex/jmd")
path_src = joinpath(path, "JchemoDemo/Ex/src")
## End

nam = "Exploratory/Pca"
zpath = joinpath(path_jmd, nam)
@show f = filter(endswith("jmd"), readdir(zpath))
nf = length(f) 
for i = 1:nf 
    #i = 4
    @show string("-------- script:", i)
    @show f[i]
    f[i]
    db = joinpath(zpath, f[i])
    out_path = joinpath(path_src, nam)
    Weave.tangle(db; out_path = out_path)
end








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
zpath = joinpath(path_jmd, nam)
@show f = filter(endswith("jmd"), readdir(zpath))
nf = length(f) 
for i = 1:nf 
    @show i
    @show f[i]
    #i = 11
    f[i]
    db = joinpath(zpath, f[i])
    out_path = joinpath(path_src, nam)
    Weave.tangle(db; out_path = out_path)
end
