using JLD2, CairoMakie, GLMakie
using Jchemo, JchemoData

CairoMakie.activate!()
#GLMakie.activate!() 

mypath = dirname(dirname(pathof(JchemoData)))
db = joinpath(mypath, "data", "cassav.jld2") 
@load db dat
pnames(dat)
  
X = dat.X 
Y = dat.Y
y = Y.tbc    
year = Y.year
wl = names(X)
wl_num = parse.(Float64, wl)
tab(year)

lev = sort(unique(year))
nlev = length(lev)
group_num = recodcat2int(year)

fm = pcasvd(X; nlv = 6) ; 
T = fm.T

## 2-D Score space
i = 1
plotxy(T[:, i], T[:, i + 1]; color = (:red, .5),
    xlabel = string("PC", i), ylabel = string("PC", i + 1),
    zeros = true, markersize = 15).f

i = 1
plotxy(T[:, i], T[:, i + 1], year;
    xlabel = string("PC", i), ylabel = string("PC", i + 1),
    zeros = true, ellipse = true).f

i = 1
colm = cgrad(:Dark2_5, nlev; categorical = true, alpha = .8)
plotxy(T[:, i], T[:, i + 1], year; 
    color = colm,
    xlabel = string("PC", i), ylabel = string("PC", i + 1),
    zeros = true, ellipse = true).f

## 3-D Score space 
CairoMakie.activate!()  
#GLMakie.activate!() 
i = 1
f = Figure(resolution = (600, 400))
ax = Axis3(f[1, 1]; perspectiveness = 0.2,
    xlabel = string("PC", i), ylabel = string("PC", i + 1), zlabel = string("PC", i + 2), 
    title = "PCA score space")
scatter!(ax, T[:, i], T[:, i + 1], T[:, i + 2];
    markersize = 15, color = (:red, .5))
f

i = 1
f = Figure(resolution = (700, 500))
colsh = :Dark2_5 #:default, :tab10
colm = cgrad(colsh, nlev; alpha = .7, categorical = true) 
ax = Axis3(f[1, 1]; perspectiveness = 0.2,
    xlabel = string("PC", i), ylabel = string("PC", i + 1), 
    zlabel = string("PC", i + 2), 
    title = "PCA score space") 
scatter!(ax, T[:, i], T[:, i + 1], T[:, i + 2], 
    markersize = 15, color = group_num, colormap = colm)
lab = string.(lev)
elt = [MarkerElement(color = colm[i], marker = '●', markersize = 10) for i in 1:nlev]
title = "Year"
Legend(f[1, 2], elt, lab, title; 
    nbanks = 1, rowgap = 10, framevisible = false)
f

