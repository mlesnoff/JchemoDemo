
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


plotxy(T[:, 1], T[:, 2]; zeros = true,
    xlabel = "PC1", ylabel = "PC2").f


i = 1
plotxy(T[:, i], T[:, i + 1]; color = (:red, .5),
    xlabel = string("PC", i), ylabel = string("PC", i + 1),
    zeros = true, markersize = 15).f


f = Figure(resolution = (600, 400))     
ax = list(4)
l = reshape(1:4, 2, 2)
for j = 1:2
    for k = 1:2
        zl = l[j, k]
        ax[zl] = Axis(f[j, k],
            xlabel = string("PC", zl), ylabel = string("PC", zl + 1))
        scatter!(ax[zl], T[:, zl:(zl + 1)];
            color = (:red, .5))
    end
end
f


CairoMakie.activate!()  
#GLMakie.activate!()


i = 1
f = Figure(resolution = (700, 500))
ax = Axis3(f[1, 1]; perspectiveness = 0.2,
    xlabel = string("PC", i), ylabel = string("PC", i + 1),
    zlabel = string("PC", i + 2), title = "PCA score space")
scatter!(ax, T[:, i], T[:, i + 1], T[:, i + 2],
    markersize = 15)
f


CairoMakie.activate!()  
#GLMakie.activate!()


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

