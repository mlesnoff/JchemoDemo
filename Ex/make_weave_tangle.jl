using Weave

path = "C:/Users/lesnoff/.julia/dev"
path_jmd = joinpath(path, "JchemoDemo/Ex/jmd")
path_src = joinpath(path, "JchemoDemo/Ex/src")

nam = "swissroll"
zpath = joinpath(path_jmd, nam)
@show f = filter(endswith("jmd"), readdir(zpath))
nf = length(f) 
for i = 1:nf 
    @show i
    @show f[i]
    #i = 11
    f[i]
    db = joinpath(zpath, f[i])
    out_path = joinpath(path_src, meth)
    Weave.tangle(db; out_path = out_path)
end
