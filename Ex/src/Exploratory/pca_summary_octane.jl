
using Jchemo, JchemoData
using JLD2, CairoMakie, GLMakie


CairoMakie.activate!()
#GLMakie.activate!()


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/octane.jld2") 
@load db dat
pnames(dat)


X = dat.X 
n = nro(X)


@head X


wlst = names(X)
wl = parse.(Float64, wlst)


plotsp(X, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance", title = "Octane data").f


model = pcasvd(nlv = 6) 
## For robust PCA, do:
#model = pcasph; nlv = 6)
## or:
#model = pcaout; nlv = 6)
fit!(model, X)  
pnames(model)
pnames(model.fitm)


res = summary(model, X) ;
pnames(res)


z = res.explvarx


plotgrid(z.nlv, 100 * z.pvar; step = 1, xlabel = "nb. PCs", ylabel = "% variance explained").f


z = res.contr_ind


i = 1
scatter(z[:, i]; axis = (xlabel = "Observation", ylabel = "Contribution", title = string("PC", i)))


plotxy(1:n, z[:, i]; xlabel = "Observation", ylabel = "Contribution", title = string("PC", i)).f


z = res.contr_var


i = 1
scatter(z[:, i], z[:, i + 1])


z = res.cor_circle


i = 1
plotxy(z[:, i], z[:, (i + 1)]; size = (400, 400), circle = true, zeros = true, 
    xlabel = string("PC", i), ylabel = string("PC", i + 1)).f

