
using JLD2, CairoMakie, StatsBase
using Jchemo, JchemoData


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


lev = unique(year)
nlev = length(lev)


wl = names(X)
wl_num = parse.(Float64, wl)


tab(year)


plotsp(X, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


f = 15 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d)


plotsp(Xp, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


fm = pcasvd(Xp, nlv = 10) ; 
pnames(fm)


T = fm.T
@head T


res = summary(fm, Xp) ;
pnames(res)


z = res.explvarx


plotgrid(z.lv, 100 * z.pvar; step = 1,
    xlabel = "Nb. PCs", ylabel = "% variance explained").f


i = 1
plotxy(T[:, i], T[:, i + 1]; color = (:red, .5),
    xlabel = "PC1", ylabel = "PC2").f


plotxy(T[:, i], T[:, i + 1], year; ellipse = true,
    xlabel = "PC1", ylabel = "PC2").f


summ(y)


f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1], xlabel = "TBC", ylabel = "Nb. samples")
hist!(ax, y; bins = 50)
f


f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1], xlabel = "Year", ylabel = "TBC")
boxplot!(ax, year, y; show_notch = true)
f


f = Figure(resolution = (500, 1000))
ax = list(nlev)
for i = 1:nlev
    i == nlev ? xlab = "tbc" : xlab = ""
    ax[i] = Axis(f[i, 1], title = string(lev[i]),
        xlabel = xlab, 
        ylabel = "Nb. obs.")
    xlims!(0, maximum(y))
    s = year .== lev[i]
    hist!(ax[i], y[s]; bins = 30,
        color = (:red, .5))
end
f

