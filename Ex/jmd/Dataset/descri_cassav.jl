using JLD2, CairoMakie, StatsBase
using Jchemo, JchemoData

```julia
using JchemoData, JLD2, CairoMakie
path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/cassav.jld2")
@load db dat
pnames(dat)

```julia
X = dat.X
Y = dat.Y 
ntot = nro(X)

```julia term = true
@head X
@head Y

```julia 
summ(Y)

```julia 
y = dat.Y.tbc
year = dat.Y.year

```julia
lev = unique(year)
nlev = length(lev)

```julia
wl = names(X)
wl_num = parse.(Float64, wl) 

```julia
tab(year)

```julia
plotsp(X, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

```julia
f = 15 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) 

plotsp(Xp, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

```julia
#### PCA
fm = pcasvd(Xp, nlv = 10) ; 
pnames(fm)

```julia term = true
T = fm.T
@head T

```julia
res = summary(fm, Xp) ;
pnames(res)

```julia
z = res.explvarx

```julia
plotgrid(z.lv, 100 * z.pvar; step = 1,
    xlabel = "Nb. PCs", ylabel = "% variance explained").f

```julia
i = 1
plotxy(T[:, i:(i + 1)]; color = (:red, .5),
    xlabel = "PC1", ylabel = "PC2").f

```julia
plotxy(T[:, i:(i + 1)], year; ellipse = true,
    xlabel = "PC1", ylabel = "PC2").f

```julia
## Variable y
summ(y)

```julia
f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1], xlabel = "TBC", ylabel = "Nb. samples")
hist!(ax, y; bins = 50)
f

```julia
f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1], xlabel = "Year", ylabel = "TBC")
boxplot!(ax, year, y; show_notch = true)
f

```julia
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
