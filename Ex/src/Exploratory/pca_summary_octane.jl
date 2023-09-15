
using JLD2, CairoMakie, GLMakie
using Jchemo, JchemoData


CairoMakie.activate!()
#GLMakie.activate!()


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/octane.jld2") 
@load db dat
pnames(dat)


X = dat.X 
n = nro(X)


@head X


wl = names(X)
wl_num = parse.(Float64, wl)


plotsp(X, wl_num;
    xlabel ="Wavelength (nm)", ylabel = "Absorbance",
    title = "Octane data").f


fm = pcasvd(X; nlv = 6) ; 
## For robust spherical PCA, do:
#fm = pcasph(X; nlv = 6) ;  
pnames(fm)


T = fm.T ;
@head T


res = summary(fm, X) ;
pnames(res)


z = res.explvarx


plotgrid(z.lv, 100 * z.pvar; step = 1,
    xlabel = "nb. PCs", ylabel = "% variance explained").f


z = res.contr_ind


i = 1
scatter(z[:, i];
    axis = (xlabel = "Observation", ylabel = "Contribution", 
        title = string("PC", i)))


plotxy(1:n, z[:, i];
    xlabel = "Observation", ylabel = "Contribution", 
    title = string("PC", i)).f


z = res.contr_var


i = 1
scatter(z[:, i], z[:, i + 1])


z = res.cor_circle


i = 1
plotxy(z[:, i], z[:, (i + 1)]; resolution = (400, 400),
    circle = true, zeros = true,
    xlabel = string("PC", i), 
    ylabel = string("PC", i + 1)).f

