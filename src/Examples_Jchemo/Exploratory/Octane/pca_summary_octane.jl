using JLD2, CairoMakie, GLMakie
using Jchemo, JchemoData
CairoMakie.activate!()

mypath = dirname(dirname(pathof(JchemoData)))
db = joinpath(mypath, "data", "octane.jld2") 
@load db dat
pnames(dat)
  
X = dat.X 
wl = names(X)
wl_num = parse.(Float64, wl)

## Model fitting
fm = pcasvd(X; nlv = 6) ; 
#fm = pcasph(X; nlv = 6) ;    # Robust PCA 
pnames(fm)

## Summary of the fitted model
res = summary(fm, X) ;
pnames(res)

## % Variance explained
z = res.explvarx
plotgrid(z.lv, 100 * z.pvar; step = 1,
    xlabel = "nb. PCs", ylabel = "% variance explained").f

## Individuals' contributions to scores
z = res.contr_ind
i = 1
scatter(z[:, i];
    axis = (xlabel = "Observation", ylabel = "Contribution", 
        title = string("PC", i)))

## Variables' contributions
z = res.contr_var 
i = 1
scatter(z[:, i], z[:, i + 1])

## Correlation circle
z = res.cor_circle
i = 1
plotxy(z[:, i], z[:, i + 1]; resolution = (400, 400),
    circle = true, zeros = true,
    xlabel = string("PC", i), 
    ylabel = string("PC", i + 1)).f

