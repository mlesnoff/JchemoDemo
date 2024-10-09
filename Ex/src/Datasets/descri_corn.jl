
using Jchemo, JchemoData
using JLD2, CairoMakie, FreqTables
using GLMakie
CairoMakie.activate!()


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/corn.jld2") 
@load db dat
pnames(dat)


Xm5 = dat.Xm5
Xmp5 = dat.Xmp5
Xmp6 = dat.Xmp6
Xm5nbs = dat.Xm5nbs
Xmp5nbs = dat.Xmp5nbs
Xmp6nbs = dat.Xmp6nbs


Y = dat.Y 
ntot = nro(Xm5)


wlst = names(dat.Xm5)
wl = parse.(Float64, wlst)


summ(Y).res


plotsp(Xm5, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


typ = [repeat(["m5"], ntot); repeat(["mp5"], ntot); repeat(["mp6"], ntot)]
typ_num = recod_catbyint(typ)


lev = mlev(typ)
nlev = length(lev)


model1 = snv)
model2 = savgol; npoint = 11, deriv = 2, degree = 3)
model = pip(model1, model2)
fit!(model, Xm5)
Xpm5 = transf(model, Xm5)
Xpmp5 = transf(model, Xmp5)
Xpmp6 = transf(model, Xmp6)


zX = vcat(Xpm5, Xpmp5, Xpmp6)
model = pcasvd; nlv = 10)
fit!(model, zX)
T = model.fitm.T


res = summary(model, zX).explvarx


plotgrid(res.nlv, res.pvar; step = 1, xlabel = "Nb. PCs", ylabel = "% explained variance").f


i = 1
plotxy(T[:, i], T[:, i + 1], typ; xlabel = string("PC", i), ylabel = string("PC", i + 1)).f


CairoMakie.activate!()
#GLMakie.activate!() 
colsh = :default    # :tab10
colm = cgrad(colsh, 10; alpha = .7, categorical = true)[[1, 5, 8]]
i = 1
f = Figure(size = (600, 500))
ax = Axis3(f[1, 1]; perspectiveness = 0.2, xlabel = string("PC", i), 
    ylabel = string("PC", i + 1), zlabel = string("PC", i + 2), title = "PCA score space") 
scatter!(ax, T[:, i], T[:, i + 1], T[:, i + 2]; markersize = 15, color = typ_num, 
    colormap = colm)
elt = [MarkerElement(color = colm[i], marker = '●', markersize = 10) for i in 1:nlev]
title = "Machine"
Legend(f[1, 2], elt, lev, title; nbanks = 1, rowgap = 10, framevisible = false)
f

