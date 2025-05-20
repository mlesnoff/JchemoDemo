using Weave

## Global paths
path = "C:/Users/lesnoff/.julia/dev"
path_jmd = joinpath(path, "JchemoDemo/Ex/jmd")
path_html = joinpath(path, "JchemoDemo/docs/src/assets/html")
## End

nam = "Exploratory/Pca"
#nam = "Regression/Plsr"
#nam = "Regression/Others"
path_scripts = joinpath(path_jmd, nam)
@show f = filter(endswith("jmd"), readdir(path_scripts))
nf = length(f) 
for i = 1:nf 
    #i = 4
    @show string("-------- script: ", i)
    @show f[i]
    f[i]
    nam_script = joinpath(path_scripts, f[i])
    out_path = joinpath(path_html, nam)
    println("Time")
    @time weave(nam_script; out_path, doctype = "md2html", fig_path = nothing, fig_ext = nothing)
end


