using JLD2, CairoMakie, StatsBase
using Jchemo, JchemoData

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

######## End Data

fm = pcasvd(X, nlv = 6) ; 
T = fm.T

i = 1
plotxy(T[:, i], T[:, i + 1]; color = (:red, .5),
    xlabel = string("PC", i), ylabel = string("PC", i + 1),
    zeros = true).f

i = 1
plotxy(T[:, i], T[:, i + 1], year;
    xlabel = string("PC", i), ylabel = string("PC", i + 1),
    zeros = true).f





plotxy(T[:, 1], T[:, 2]; 
    xlabel = "PC1", ylabel = "PC2").f

i = 1
plotxy(T[:, i], T[:, i + 1]; color = (:red, .5),
    xlabel = string("PC", i), ylabel = string("PC", i + 1),
    zeros = true).f

f = Figure(resolution = (700, 500))     
ax = list(4)
i = 1
for j = 1:2
    for k = 1:2
        ax[i] = Axis(f[j, k],
            xlabel = string("PC", i), ylabel = string("PC", i + 1))
        scatter!(ax[i], T[:, i], T[:, i + 1];
            color = (:red, .5))
        i = i + 1
    end
end
f    

GLMakie.activate!() 
#CairoMakie.activate!()  
i = 1
f = Figure(resolution = (700, 500))
ax = Axis3(f[1, 1]; perspectiveness = 0.2,
    xlabel = string("PC", i), ylabel = string("PC", i + 1),
    zlabel = string("PC", i + 2), title = "PCA score space")
scatter!(ax, T[:, i], T[:, i + 1], T[:, i + 2],
    markersize = 15)
f

GLMakie.activate!() 
#CairoMakie.activate!()  
i = 1
f = Figure(resolution = (700, 500))
ax = Axis3(f[1, 1]; perspectiveness = 0.2,
    xlabel = string("PC", i), ylabel = string("PC", i + 1),
    zlabel = string("PC", i + 2), title = "PCA score space")
scatter!(ax, T[:, i], T[:, i + 1], T[:, i + 2],
    markersize = 15)
text!(ax, T[:, i], T[:, i + 1], T[:, i + 2]; 
    text = string.(1:n), fontsize = 15)
f



