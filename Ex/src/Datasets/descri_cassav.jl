
using Jchemo, JchemoData
using JLD2, CairoMakie


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


summ(Y)


y = dat.Y.tbc
year = dat.Y.year


lev = mlev(year)
nlev = length(lev)


wlst = names(X)
wl = parse.(Float64, wlst)


tab(year)


plotsp(X, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


model1 = snv)
model2 = savgol; npoint = 11, deriv = 2, degree = 3)
model = pip(model1, model2)
fit!(model, X)
Xp = transf(model, X)


plotsp(Xp, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


model = pcasvd; nlv = 10)
fit!(model, Xp)
pnames(model)
pnames(model.fitm)


@head T = model.fitm.T


res = summary(model, Xp) ;
pnames(res)


z = res.explvarx


plotgrid(z.nlv, 100 * z.pvar; step = 1, xlabel = "Nb. PCs", 
    ylabel = "% variance explained").f


i = 1
plotxy(T[:, i], T[:, i + 1]; color = (:red, .5), xlabel = "PC1", ylabel = "PC2").f


plotxy(T[:, i], T[:, i + 1], year; ellipse = true, xlabel = "PC1", ylabel = "PC2").f


summ(y)


f = Figure(size = (500, 400))
ax = Axis(f[1, 1]; xlabel = "TBC", ylabel = "Nb. samples")
hist!(ax, y; bins = 50)
f


f = Figure(size = (500, 400))
ax = Axis(f[1, 1]; xlabel = "Year", ylabel = "TBC")
boxplot!(ax, year, y; show_notch = true)
f


f = Figure(size = (500, 1000))
ax = list(nlev)
for i = 1:nlev
    i == nlev ? xlab = "tbc" : xlab = ""
    ax[i] = Axis(f[i, 1], title = string(lev[i]), xlabel = xlab, ylabel = "Nb. obs.")
    xlims!(0, maximum(y))
    s = year .== lev[i]
    hist!(ax[i], y[s]; bins = 30, color = (:red, .5))
end
f

