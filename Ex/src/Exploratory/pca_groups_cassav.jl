
using Jchemo, JchemoData
using JLD2, CairoMakie, GLMakie


CairoMakie.activate!()
#GLMakie.activate!()


using JchemoData, JLD2, CairoMakie
path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/cassav.jld2")
@load db dat
pnames(dat)


X = dat.X
Y = dat.Y
ntot = nro(X)


@head X
@head Y


y = dat.Y.tbc
year = dat.Y.year


wlst = names(X)
wl = parse.(Float64, wlst)


tab(year)


lev = mlev(year)


nlev = length(lev)


groupnum = recod_catbyint(year)


plotsp(X, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


mod1 = model(snv)
mod2 = model(savgol; npoint = 15, deriv = 2, degree = 3)
mod = pip(mod1, mod2)
fit!(mod, X)
Xp = transf(mod, X)


plotsp(Xp, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


mod = model(pcasvd; nlv = 6)
fit!(mod, Xp)


@head T = mod.fm.T


i = 1
plotxy(T[:, i], T[:, i + 1]; color = (:red, .5), xlabel = string("PC", i), 
    ylabel = string("PC", i + 1), zeros = true, markersize = 15).f


i = 1
plotxy(T[:, i], T[:, i + 1], year; xlabel = string("PC", i), 
    ylabel = string("PC", i + 1), zeros = true, ellipse = true).f


i = 1
colm = cgrad(:Dark2_5, nlev; categorical = true, alpha = .8)
plotxy(T[:, i], T[:, i + 1], year;  color = colm, xlabel = string("PC", i), 
    ylabel = string("PC", i + 1), zeros = true, ellipse = true).f


CairoMakie.activate!()  
#GLMakie.activate!() 
i = 1
f = Figure(size = (600, 400))
ax = Axis3(f[1, 1]; perspectiveness = 0.2, xlabel = string("PC", i), 
    ylabel = string("PC", i + 1), zlabel = string("PC", i + 2), title = "PCA score space")
scatter!(ax, T[:, i], T[:, i + 1], T[:, i + 2]; markersize = 15, color = (:red, .5))
f


i = 1
f = Figure(size = (700, 500))
colsh = :Dark2_5 #:default, :tab10
colm = cgrad(colsh, nlev; alpha = .7, categorical = true) 
ax = Axis3(f[1, 1]; perspectiveness = 0.2, xlabel = string("PC", i), 
    ylabel = string("PC", i + 1), zlabel = string("PC", i + 2), title = "PCA score space") 
scatter!(ax, T[:, i], T[:, i + 1], T[:, i + 2], markersize = 15, color = year, 
    colormap = colm)
elt = [MarkerElement(color = colm[i], marker = '●', markersize = 10) for i in 1:nlev]
lab = string.(lev)
title = "Year"
Legend(f[1, 2], elt, lab, title; nbanks = 1, rowgap = 10, framevisible = false)
f

