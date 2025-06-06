
using Jchemo, JchemoData
using JLD2, DataFrames, CairoMakie


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/cassav.jld2")
@load db dat
@names dat


X = dat.X ;
Y = dat.Y ;
@head X
@head Y
ntot = nro(X)


wlst = names(X) 
wl = parse.(Int, wlst) ;


plotsp(X, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


model1 = snv()
model2 = savgol(npoint = 15, deriv = 2, degree = 3)
model = pip(model1, model2) ;
fit!(model, X)
Xp = transf(model, X) ;
@head Xp


plotsp(Xp, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


summ(Y).res


year = Y.year ;
tab(year)


y = Y.tbc ;
summ(y).res


f = Figure(size = (400, 300))
ax = Axis(f[1, 1]; xlabel = "TBC", ylabel = "Nb. observations")
hist!(ax, y; bins = 30, label = "Train")
f


f = Figure(size = (400, 300))
ax = Axis(f[1, 1]; xlabel = "TBC", ylabel = "Density")
density!(ax, y; bandwidth = .2, color = (:red, .5))
f


y = Y.tbc ;
summ(y, year)


f = Figure(size = (400, 300))
ax = Axis(f[1, 1]; xlabel = "Year", ylabel = "TBC")
boxplot!(ax, year, y; width = .7, show_notch = true)
f

