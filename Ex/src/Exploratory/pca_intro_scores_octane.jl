
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


mod = pcasvd(nlv = 6) 
## For robust spherical PCA, do:
#mod = pcasph(nlv = 6)
fit!(mod, X)  
pnames(mod)
pnames(mod.fm)


@head T = mod.fm.T


plotxy(T[:, 1], T[:, 2]; zeros = true, xlabel = "PC1", ylabel = "PC2").f


i = 1
plotxy(T[:, i], T[:, i + 1]; color = (:red, .5), xlabel = string("PC", i), 
    ylabel = string("PC", i + 1), zeros = true, markersize = 15).f


f = Figure(size = (600, 400))     
ax = list(4)
l = reshape(1:4, 2, 2)
for j = 1:2
    for k = 1:2
        zl = l[j, k]
        ax[zl] = Axis(f[j, k], xlabel = string("PC", zl), ylabel = string("PC", zl + 1))
        scatter!(ax[zl], T[:, zl:(zl + 1)]; color = (:red, .5))
    end
end
f


CairoMakie.activate!()  
#GLMakie.activate!()


i = 1
f = Figure(size = (700, 500))
ax = Axis3(f[1, 1]; perspectiveness = 0.2, xlabel = string("PC", i), 
    ylabel = string("PC", i + 1), zlabel = string("PC", i + 2), title = "PCA score space")
scatter!(ax, T[:, i], T[:, i + 1], T[:, i + 2], markersize = 15)
f


CairoMakie.activate!()  
#GLMakie.activate!()


i = 1
f = Figure(size = (700, 500))
ax = Axis3(f[1, 1]; perspectiveness = 0.2, xlabel = string("PC", i), 
    ylabel = string("PC", i + 1), zlabel = string("PC", i + 2), title = "PCA score space")
scatter!(ax, T[:, i], T[:, i + 1], T[:, i + 2], markersize = 15)
text!(ax, T[:, i], T[:, i + 1], T[:, i + 2]; text = string.(1:n), fontsize = 15)
f

