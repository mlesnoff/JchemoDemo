using JLD2, CairoMakie, GLMakie
using Jchemo, JchemoData
CairoMakie.activate!()  

path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/octane.jld2") 
@load db dat
pnames(dat)
  
X = dat.X 
wl = names(X)
wl_num = parse.(Float64, wl)
n = nro(X)

## Six of the samples of the dataset contain 
## added alcohol  (= 25, 26, and 36-39)
plotsp(X, wl_num;
    xlabel ="Wavelength (nm)", ylabel = "Absorbance",
    title = "Octane data").f

## Model fitting
fm = pcasvd(X; nlv = 6) ; 
## Robust PCA
#fm = pcasph(X; nlv = 6) ;  
## End 
pnames(fm)

T = fm.T

## 2-D Score space 
plotxy(T[:, 1], T[:, 2]; zeros = true,
    xlabel = "PC1", ylabel = "PC2").f

i = 1
plotxy(T[:, i], T[:, i + 1]; color = (:red, .5),
    xlabel = string("PC", i), ylabel = string("PC", i + 1),
    zeros = true, markersize = 15).f

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

## 3-D Score space
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


