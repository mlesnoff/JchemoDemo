
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


model0 = pcasvd(nlv = 6) 
## For robust PCA, do:
#model0 = pcasph(; nlv = 6)
## or:
#model0 = pcaout(; nlv = 6)
fit!(model0, X)  
pnames(model0)
pnames(model0.fitm)


@head T = model0.fitm.T


model = occsd()
fit!(model, model0.fitm)
pnames(model)
pnames(model.fitm)


d = model.fitm.d


f = Figure(size = (500, 400))
Axis(f[1, 1]; xlabel = "Standardized score distance", ylabel = "Nb. observations")
hist!(d.dstand; bins = 20)
f


model = occod() 
fit!(model, model0.fitm, X)
pnames(model)
pnames(model.fitm)


d = model.fitm.d


f = Figure(size = (500, 400))
Axis(f[1, 1]; xlabel = "Standardized orthogonal distance", ylabel = "Nb. observations")
hist!(d.dstand; bins = 20)
f


model = occsd()
fit!(model, model0.fitm)
d_sd = model.fitm.d
model = occod()
fit!(model, model0.fitm, X)
d_od = model.fitm.d
f, ax = plotxy(d_sd.dstand, d_od.dstand; xlabel = "Standardized SD", ylabel = "Standardized OD")
hlines!(ax, 1; color = :grey, linestyle = :dash)
vlines!(ax, 1; color = :grey, linestyle = :dash)
f


f, ax = plotxy(d_sd.dstand, d_od.dstand; xlabel = "Standardized SD", ylabel = "Standardized OD")
text!(ax, d_sd.dstand, d_od.dstand; text = string.(1:n), fontsize = 15)
hlines!(ax, 1; color = :grey, linestyle = :dash)
vlines!(ax, 1; color = :grey, linestyle = :dash)
f


model = occsdod() 
fit!(model, model0.fitm, X)
pnames(model)
pnames(model.fitm)


d = model.fitm.d


f, ax = plotxy(1:n, d.dstand; xlabel = "Observation", ylabel = "Standardized SD-OD distance")
text!(ax, 1:n, d.dstand; text = string.(1:n), fontsize = 15)
hlines!(ax, 1; color = :grey, linestyle = :dash)
f

