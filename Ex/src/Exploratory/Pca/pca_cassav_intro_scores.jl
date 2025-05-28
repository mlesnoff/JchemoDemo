
using Jchemo, JchemoData
using JLD2, CairoMakie, GLMakie


using JchemoData, JLD2, CairoMakie, GLMakie
path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/cassav.jld2")
@load db dat
@names dat


X = dat.X
names(X)


model = pcasvd(nlv = 10)
fit!(model, X)  
@names model


fitm = model.fitm ; 
@names fitm


@head T = fitm.T


@head transf(model, X)


res = summary(model, X) ;
@names res


pcts = res.explvarx


CairoMakie.activate!()
plotgrid(pcts.nlv, 100 * pcts.pvar; step = 1, xlabel = "nb. PCs", ylabel = "% variance explained").f


plotxy(T[:, 1], T[:, 2]; zeros = true, xlabel = "PC1", ylabel = "PC2").f


plotlv(T[:, 1:6]; shape = (2, 3), color = (:blue, .5), zeros = true, xlabel = "PC", 
    ylabel = "PC").f


CairoMakie.activate!()  
#GLMakie.activate!()    # for interactive axe-rotation

i = 1
size = (600, 350)
plotxyz(T[:, i], T[:, i + 1], T[:, i + 2]; size, color = (:red, .3), markersize = 10, 
    xlabel = string("PC", i), ylabel = string("PC", i + 1), zlabel = string("PC", i + 2), 
    title = "Pca score space").f

