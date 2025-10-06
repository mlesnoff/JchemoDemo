
using Jchemo, JchemoData
using JLD2, CairoMakie, GLMakie


using JchemoData, JLD2, CairoMakie, GLMakie
path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/cassav.jld2")
@load db dat
@names dat


X = dat.X
@head X


Y = dat.Y
@head Y


year = Y.year
tab(year)


model = pcasvd(nlv = 10)
fit!(model, X)  
fitm = model.fitm
@head T = fitm.T


CairoMakie.activate!()  
plotxy(T[:, 1], T[:, 2], year; zeros = true, xlabel = "PC1", ylabel = "PC2").f


lev = mlev(year)
nlev = length(lev)
color = cgrad(:Dark2_5, nlev; categorical = true, alpha = .7)
plotlv(T[:, 1:6], year; size = (750, 400), shape = (2, 3), color = color, zeros = true, xlabel = "PC", ylabel = "PC").f


CairoMakie.activate!()  
#GLMakie.activate!()    # for interactive axe-rotation

i = 1
size = (600, 350)
plotxyz(T[:, i], T[:, i + 1], T[:, i + 2], year; size, color, markersize = 10, xlabel = "PC$i", ylabel = "PC$(i + 1)", 
    zlabel = string("PC", i + 2), title = "Pca score space").f

