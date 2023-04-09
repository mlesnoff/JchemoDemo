using JLD2, CairoMakie, StatsBase
using Jchemo, JchemoData

path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data", "cassav.jld2") 
@load db dat
pnames(dat)
  
X = dat.X 
Y = dat.Y
y = Y.tbc    
year = Y.year
tab(year)
wl = names(X)
wl_num = parse.(Float64, wl)

summ(X).res

lev = mlev(year)
nlev = length(lev) 

## Spectra
plotsp(X, wl_num; nsamp = 10, 
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

## Preprocessing
Xp = savgol(snv(X); f = 21, pol = 3, d = 2)

plotsp(Xp, wl_num; nsamp = 10,
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

#### PCA
fm = pcasvd(Xp, nlv = 10) ; 
pnames(fm)
T = fm.T

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

## Variable y
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



