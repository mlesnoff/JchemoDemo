using Weave

## Global paths
path = "C:/Users/lesnoff/.julia/dev"
path_jmd = joinpath(path, "JchemoDemo/Ex/jmd")
path_src = joinpath(path, "JchemoDemo/Ex/src")
## End

nam = "ImportExport"
#nam = "Datasets"
#nam = "Exploratory/Pca"
#nam = "Exploratory/Fda"
#nam = "Regression/Prediction"
#nam = "Regression/Gridscore"
#nam = "Regression/Gridcv"
#nam = "Discrimination/Prediction"
#nam = "Discrimination/Gridscore"
#nam = "Discrimination/Gridcv"
#nam = "Notes"
path_scripts = joinpath(path_jmd, nam)
@show f = filter(endswith("jmd"), readdir(path_scripts))
nf = length(f) 
for i = 1:nf 
    #i = 4
    @show string("-------- script:", i)
    @show f[i]
    f[i]
    db = joinpath(path_scripts, f[i])
    out_path = joinpath(path_src, nam)
    Weave.tangle(db; out_path)
end

