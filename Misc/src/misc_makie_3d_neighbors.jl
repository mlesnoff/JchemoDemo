using JLD2, CairoMakie, GLMakie
using Jchemo, JchemoData

path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data", "cassav.jld2")
@load db dat
@names dat
X = dat.X

## Nearest neighbors
model = pcasvd(nlv = 3) 
Jchemo.fit!(model, X) 
T = model.fitm.T
i = 10 ; k = 50
res = getknn(T, T[i:i, :]; k = k, metric = :mah)
s = res.ind[1]
CairoMakie.activate!() ;  
#GLMakie.activate!() ;  
f = Figure(size = (600, 500))
mks = 15 ; tsp = .5
ax = Axis3(f[1, 1]; xlabel = "PC1", ylabel = "PC2", zlabel = "PC3", perspectiveness = 0.5) 
scatter!(ax, T[:, 1], T[:, 2], T[:, 3]; markersize = mks, color = (:grey, tsp))
scatter!(ax, T[s, 1], T[s, 2], T[s, 3]; markersize = mks, color = (:blue, tsp))
scatter!(ax, T[i:i, 1], T[i:i, 2], T[i:i, 3]; markersize = mks, color = (:red, tsp))
cols = [:grey; :blue; :red]
elt = [MarkerElement(color = cols[i], marker = '●', markersize = 10) for i in 1:3]
lab = ["Training"; "Neighborhood"; "To predict"]
title = "kNN selection"
Legend(f[1, 2], elt, lab, title; nbanks = 1, rowgap = 10, framevisible = false)
f


